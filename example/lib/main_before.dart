// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:flutter/services.dart';
// import 'package:bootpay_webview_flutter/webview_flutter.dart';
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final Completer<WebViewController> _controller = Completer<WebViewController>();
//
//   loadHtmlFromAssets() async {
//     String fileText = await rootBundle.loadString('assets/index.html');
//     print(fileText);
//     _controller.future.then((controller) {
//       controller.loadUrl(Uri.dataFromString(
//           fileText,
//           mimeType: 'text/html',
//           encoding: Encoding.getByName('utf-8')
//       ).toString());
//     });
//
//     // _controller.future.loadUrl( Uri.dataFromString(
//     //     fileText,
//     //     mimeType: 'text/html',
//     //     encoding: Encoding.getByName('utf-8')
//     // ).toString());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Builder(builder: (BuildContext context) {
//           return WebView(
//
//             // initialUrl: 'https://d-cdn.bootapi.com/test/payment',
//             javascriptMode: JavascriptMode.unrestricted,
//             onWebViewCreated: (WebViewController webViewController) {
//               _controller.complete(webViewController);
//               loadHtmlFromAssets();
//               // _controller.future.then((controller) {
//               //   controller.loadUrl(url)
//               // });
//             },
//             onProgress: (int progress) {
//               print("WebView is loading (progress : $progress%)");
//             },
//             javascriptChannels: <JavascriptChannel>[
//               onCancel(context),
//               onError(context),
//               onClose(context),
//               onReady(context),
//               onConfirm(context),
//               onDone(context)
//             ].toSet(),
//             navigationDelegate: (NavigationRequest request) {
//               if (request.url.startsWith('https://www.youtube.com/')) {
//                 print('blocking navigation to $request}');
//                 return NavigationDecision.prevent;
//               }
//               print('allowing navigation to $request');
//               return NavigationDecision.navigate;
//             },
//             onPageStarted: (String url) {
//               print('Page started loading: $url');
//             },
//             onPageFinished: (String url) {
//               print('Page finished loading: $url');
//             },
//             gestureNavigationEnabled: true,
//           );
//         }),
//       ),
//     );
//   }
// }
//
// extension BootpayEvent on _MyAppState {
//   JavascriptChannel onCancel(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayCancel',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           print('------ onCancel: ${message.message}');
//         });
//   }
//
//   JavascriptChannel onError(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayError',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           // message.
//           print('------ onError: ${message.message}');
//         });
//   }
//
//   JavascriptChannel onClose(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayClose',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           print('------ onClose: ${message.message}');
//         });
//   }
//
//   JavascriptChannel onReady(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayReady',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           print('------ onReady: ${message.message}');
//         });
//   }
//
//   JavascriptChannel onConfirm(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayConfirm',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           print('------ onConfirm: ${message.message}');
//         });
//   }
//
//   JavascriptChannel onDone(BuildContext context) {
//     return JavascriptChannel(
//         name: 'BootpayDone',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           print('------ onDone: ${message.message}');
//         });
//   }
// }