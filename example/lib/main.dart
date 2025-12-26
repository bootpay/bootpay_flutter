import 'package:flutter/material.dart';
import 'package:bootpay/bootpay.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // WebView 프리워밍 (iOS/macOS에서만 동작)
  // 첫 결제 화면 로딩 속도를 3-7초 단축합니다.
  Bootpay.warmUp();

  runApp(const BootpayExampleApp());
}

class BootpayExampleApp extends StatelessWidget {
  const BootpayExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bootpay Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF3182F6),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainMenuScreen(),
    );
  }
}
