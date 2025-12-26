import 'package:flutter/material.dart';
import 'package:bootpay/bootpay.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // WebView 프리워밍은 SDK 초기화 시 자동으로 수행됩니다 (iOS/macOS)
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
