import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bootpay/bootpay.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env 미존재 시 production fallback 으로 동작 (BootpayEnvConfig)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env 없음 — production 기본값 사용
  }
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
