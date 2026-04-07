import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {

  private var channel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    // ── Flutter ↔ Native method channel ────────────────────────────────────
    if let controller = window?.rootViewController as? FlutterViewController {
      channel = FlutterMethodChannel(
        name: "com.hyrox/watch_connectivity",
        binaryMessenger: controller.binaryMessenger
      )
      channel?.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "sendWorkoutState":
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
            return
          }
          self?.sendWorkoutStateToWatch(args)
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // ── WatchConnectivity session ──────────────────────────────────────────
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── WatchConnectivity helpers ────────────────────────────────────────────
  private func sendWorkoutStateToWatch(_ state: [String: Any]) {
    guard WCSession.default.isReachable else { return }
    WCSession.default.sendMessage(state, replyHandler: nil, errorHandler: nil)
  }

  // ── WCSessionDelegate ────────────────────────────────────────────────────
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}

  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {
    WCSession.default.activate()
  }

  // Receive control commands from the Watch (e.g. NEXT, PAUSE)
  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod("watchCommand", arguments: message)
    }
  }
}
