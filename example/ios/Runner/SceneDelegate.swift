import UIKit
import Flutter

@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Get FlutterEngine from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Create window
        window = UIWindow(windowScene: windowScene)

        // Create FlutterViewController with the pre-started engine
        let flutterViewController = FlutterViewController(engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        // Connect window to FlutterAppDelegate
        appDelegate.window = window

        // Handle URL from connectionOptions (cold start)
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) {
        // bootpayFlutterExampleV2:// scheme is for payment return
        // WebView handles the payment completion internally
        print("Bootpay: App returned with URL: \(url.absoluteString)")
    }
}
