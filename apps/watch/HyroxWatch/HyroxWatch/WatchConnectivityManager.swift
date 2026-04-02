import Foundation
import WatchConnectivity

/// Receives workout-state updates from the iPhone app via WCSession.
/// The phone sends a dictionary whenever the exercise changes.
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchConnectivityManager()

    // ── Published workout state ─────────────────────────────────────────────
    @Published var exerciseIndex: Int = 0
    @Published var exerciseName: String = ""
    @Published var isRun: Bool = false
    @Published var isRunning: Bool = false
    @Published var totalElapsedMs: Int = 0
    @Published var exerciseElapsedMs: Int = 0
    @Published var totalExercises: Int = 16
    @Published var isConnected: Bool = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // ── WCSessionDelegate ────────────────────────────────────────────────────
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.applyUpdate(message)
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        DispatchQueue.main.async {
            self.applyUpdate(applicationContext)
        }
    }

    private func applyUpdate(_ dict: [String: Any]) {
        exerciseIndex    = dict["exerciseIndex"]    as? Int    ?? exerciseIndex
        exerciseName     = dict["exerciseName"]     as? String ?? exerciseName
        isRun            = dict["isRun"]            as? Bool   ?? isRun
        isRunning        = dict["isRunning"]        as? Bool   ?? isRunning
        totalElapsedMs   = dict["totalElapsedMs"]   as? Int    ?? totalElapsedMs
        exerciseElapsedMs = dict["exerciseElapsedMs"] as? Int  ?? exerciseElapsedMs
        totalExercises   = dict["totalExercises"]   as? Int    ?? totalExercises
    }

    // ── Send commands to phone ────────────────────────────────────────────────
    func sendCommand(_ command: String) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["watchCommand": command], replyHandler: nil)
    }
}
