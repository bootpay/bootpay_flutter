import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main engine")

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("[Bootpay] AppDelegate.didFinishLaunchingWithOptions called")

        // Start Flutter engine early for plugin registration
        flutterEngine.run()
        print("[Bootpay] FlutterEngine started")

        // Register plugins with the engine
        print("[Bootpay] Calling GeneratedPluginRegistrant.register...")
        GeneratedPluginRegistrant.register(with: flutterEngine)
        print("[Bootpay] GeneratedPluginRegistrant.register completed")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - UISceneSession Lifecycle

    override func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    override func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}
