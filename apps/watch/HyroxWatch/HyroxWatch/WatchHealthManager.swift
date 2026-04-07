import Foundation
import HealthKit
import CoreLocation
import Combine

/// Manages live heart rate and GPS pace directly from Apple Watch sensors.
/// This runs independently from the phone — the watch reads its own HR
/// and GPS so data is always fresh even when the phone is in a pocket.
final class WatchHealthManager: NSObject, ObservableObject,
    CLLocationManagerDelegate {

    // ── Published metrics ──────────────────────────────────────────────────
    @Published var heartRate: Int? = nil      // bpm from optical sensor
    @Published var calories: Double = 0       // active kcal since workout start
    @Published var paceSecsPerKm: Double = 0  // live pace from GPS

    private let store = HKHealthStore()
    private var hrQuery: HKAnchoredObjectQuery?
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var workoutStart: Date?

    private let locationManager = CLLocationManager()
    private var speedWindow: [Double] = []
    private let windowSize = 5

    // ── HealthKit authorisation ────────────────────────────────────────────
    func requestAuthorisation() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let share: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate),
        ]
        let read: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate),
        ]
        store.requestAuthorization(toShare: share, read: read) { _, _ in }
    }

    // ── Workout lifecycle ──────────────────────────────────────────────────
    func startWorkout() {
        requestAuthorisation()
        workoutStart = Date()
        calories = 0

        let config = HKWorkoutConfiguration()
        config.activityType = .functionalStrengthTraining
        config.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: store, configuration: config)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: store, workoutConfiguration: config)

            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { _, _ in }

            self.startHeartRateQuery()
        } catch {
            // Fallback: query HR without a session
            startHeartRateQuery()
        }
    }

    func stopWorkout() {
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.workoutBuilder?.finishWorkout { _, _ in }
        }
        hrQuery = nil
        locationManager.stopUpdatingLocation()
    }

    // ── Heart rate streaming ──────────────────────────────────────────────
    private func startHeartRateQuery() {
        let hrType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: workoutStart ?? Date.distantPast,
            end: nil,
            options: .strictStartDate
        )

        hrQuery = HKAnchoredObjectQuery(
            type: hrType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.processHRSamples(samples)
        }

        hrQuery?.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processHRSamples(samples)
        }

        if let q = hrQuery {
            store.execute(q)
        }
    }

    private func processHRSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample],
              let latest = samples.last else { return }
        let bpm = latest.quantity.doubleValue(for: .init(from: "count/min"))
        DispatchQueue.main.async { self.heartRate = Int(bpm) }
    }

    // ── GPS pace tracking ─────────────────────────────────────────────────
    func startRunTracking() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        speedWindow.removeAll()
    }

    func stopRunTracking() {
        locationManager.stopUpdatingLocation()
        speedWindow.removeAll()
        DispatchQueue.main.async { self.paceSecsPerKm = 0 }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.last, loc.speed >= 0 else { return }
        speedWindow.append(loc.speed)
        if speedWindow.count > windowSize { speedWindow.removeFirst() }

        let avg = speedWindow.reduce(0, +) / Double(speedWindow.count)
        let pace = avg > 0.5 ? (1000.0 / avg) : 0.0 // sec/km

        DispatchQueue.main.async { self.paceSecsPerKm = pace }
    }

    // ── Formatted accessors ───────────────────────────────────────────────
    var heartRateDisplay: String {
        guard let bpm = heartRate else { return "--" }
        return "\(bpm)"
    }

    var paceDisplay: String {
        guard paceSecsPerKm > 0 else { return "--:--" }
        let m = Int(paceSecsPerKm) / 60
        let s = Int(paceSecsPerKm) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
