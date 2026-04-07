import SwiftUI

/// Shown when no workout state has been received from the phone yet.
struct WaitingView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("HYROX")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Text(connectivity.isConnected ? "[WAITING FOR PHONE...]" : "[NOT CONNECTED]")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.init(white: 0.4))
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                if connectivity.isConnected {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.init(white: 0.4))
                        .scaleEffect(0.8)
                }
            }
        }
    }
}
