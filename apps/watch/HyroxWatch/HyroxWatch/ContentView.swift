import SwiftUI

/// Root view — routes between waiting-for-phone and active-workout views.
struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @EnvironmentObject var health: WatchHealthManager

    var body: some View {
        if connectivity.exerciseName.isEmpty {
            WaitingView()
        } else if connectivity.isRun {
            RunningView()
        } else {
            ExerciseView()
        }
    }
}
