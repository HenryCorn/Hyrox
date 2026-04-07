import SwiftUI

@main
struct HyroxWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @StateObject private var healthManager = WatchHealthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
                .environmentObject(healthManager)
        }
    }
}
