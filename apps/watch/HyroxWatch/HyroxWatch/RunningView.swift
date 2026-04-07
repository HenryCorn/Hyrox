import SwiftUI

/// Apple Watch view for the 1 km run segments.
/// The "one break" in Nothing design: pace displayed in signal red.
struct RunningView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @EnvironmentObject var health: WatchHealthManager

    // Drives the centisecond counter locally without waiting for phone ticks
    @State private var localElapsedMs: Int = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Label ─────────────────────────────────────────────────
                Text("1 KM RUN")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.init(white: 0.4))
                    .tracking(2)
                    .padding(.top, 12)

                // ── Pace — the "one break" (signal red) ──────────────────
                Text(health.paceDisplay)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.843, green: 0.098, blue: 0.129)) // #D71921
                    .monospacedDigit()
                    .padding(.top, 4)

                Text("/KM")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.init(white: 0.4))
                    .tracking(2)

                Spacer()

                // ── Metrics row ───────────────────────────────────────────
                HStack(spacing: 0) {
                    _WatchMetric(
                        label: "BPM",
                        value: health.heartRateDisplay
                    )
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .frame(width: 1, height: 28)
                    _WatchMetric(
                        label: "CALS",
                        value: health.calories > 0
                            ? "\(Int(health.calories))"
                            : "--"
                    )
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .frame(width: 1, height: 28)
                    _WatchMetric(
                        label: "TIME",
                        value: _fmtMs(localElapsedMs)
                    )
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)

                // ── Progress bar ──────────────────────────────────────────
                _SegmentedBar(
                    total: connectivity.totalExercises,
                    completed: connectivity.exerciseIndex,
                    accentCurrent: true
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
        .onAppear {
            health.startRunTracking()
            startLocalTimer()
        }
        .onDisappear {
            health.stopRunTracking()
            timer?.invalidate()
        }
        .onChange(of: connectivity.exerciseElapsedMs) { ms in
            localElapsedMs = ms
        }
    }

    // ── Local centisecond clock ───────────────────────────────────────────
    private func startLocalTimer() {
        localElapsedMs = connectivity.exerciseElapsedMs
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if connectivity.isRunning {
                localElapsedMs += 100
            }
        }
    }

    private func _fmtMs(_ ms: Int) -> String {
        let s = ms / 1000
        let m = s / 60
        return String(format: "%02d:%02d", m, s % 60)
    }
}
