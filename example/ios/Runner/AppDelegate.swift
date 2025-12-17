import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 앱 스키마로 복귀 시 Navigator 꼬임 방지
  // 외부 결제 앱에서 돌아올 때 별도 처리 없이 앱만 foreground로
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // bootpayFlutterExampleV2:// 스키마는 결제 복귀용이므로 무시
    // WebView 내부에서 이미 결제 완료를 처리하고 있음
    if url.scheme == "bootpayFlutterExampleV2" {
      return true // URL 처리했음을 알리지만 아무것도 하지 않음
    }
    return super.application(app, open: url, options: options)
  }
}
