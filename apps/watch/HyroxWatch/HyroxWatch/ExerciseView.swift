import SwiftUI

/// Apple Watch view for the 8 workout station segments.
/// Timer displays in white (neutral — the run's red accent is absent).
struct ExerciseView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @EnvironmentObject var health: WatchHealthManager

    @State private var localElapsedMs: Int = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Exercise name ─────────────────────────────────────────
                Text(connectivity.exerciseName.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)

                // ── Station counter ───────────────────────────────────────
                Text("STATION \((connectivity.exerciseIndex / 2) + 1) OF 8")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.init(white: 0.4))
                    .tracking(1)
                    .padding(.top, 2)

                Spacer()

                // ── Hero timer ────────────────────────────────────────────
                Text(_fmtMs(localElapsedMs))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .monospacedDigit()

                Spacer()

                // ── BPM + calories ────────────────────────────────────────
                HStack(spacing: 0) {
                    _WatchMetric(label: "BPM", value: health.heartRateDisplay)
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .frame(width: 1, height: 28)
                    _WatchMetric(
                        label: "KCAL",
                        value: health.calories > 0
                            ? "\(Int(health.calories))"
                            : "--"
                    )
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .frame(width: 1, height: 28)
                    _WatchMetric(label: "TOTAL", value: _fmtMs(connectivity.totalElapsedMs))
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)

                // ── Progress bar ──────────────────────────────────────────
                _SegmentedBar(
                    total: connectivity.totalExercises,
                    completed: connectivity.exerciseIndex,
                    accentCurrent: false
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 8)

                // ── NEXT button ───────────────────────────────────────────
                Button {
                    connectivity.sendCommand("next")
                } label: {
                    Text("[ NEXT ]")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
        }
        .onAppear { startLocalTimer() }
        .onDisappear { timer?.invalidate() }
        .onChange(of: connectivity.exerciseElapsedMs) { ms in
            localElapsedMs = ms
        }
    }

    private func startLocalTimer() {
        localElapsedMs = connectivity.exerciseElapsedMs
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if connectivity.isRunning { localElapsedMs += 100 }
        }
    }

    private func _fmtMs(_ ms: Int) -> String {
        let s = ms / 1000
        let m = s / 60
        return String(format: "%02d:%02d", m, s % 60)
    }
}
