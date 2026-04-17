import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Bootpay 환경 설정 (example 전용)
///
/// 우선순위: .env (flutter_dotenv) → production fallback
///
/// 환경 전환 (로컬 테스트):
///   `.env`에 `BOOTPAY_ENV=development` 추가
///
/// 키 오버라이드 (로컬 테스트):
///   `.env`에 `BOOTPAY_*` 키 추가
///
/// 미설정 시 production 기본값으로 동작 (배포 안전 — production-default 규칙).
/// `.env` 파일은 `.gitignore` 처리됨. 템플릿은 `.env.example` 참고.
///
/// SDK 내부의 `BootpayConfig` 클래스(SDK 환경 스위치)와 이름 충돌을 피하기 위해
/// `BootpayEnvConfig`로 명명함.
class BootpayEnvConfig {
  // ===== Production 기본값 (fallback) =====
  static const String _prodWeb = '5b8f6a4d396fa665fdc2b5e7';
  static const String _prodAndroid = '5b8f6a4d396fa665fdc2b5e8';
  static const String _prodIos = '5b8f6a4d396fa665fdc2b5e9';
  static const String _prodRest = '5b8f6a4d396fa665fdc2b5ea';
  static const String _prodPrivateKey = 'rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=';
  static const String _prodClientKey = 'sEN72kYZBiyMNytA8nUGxQ';

  // ===== Development 기본값 =====
  static const String _devWeb = '5b9f51264457636ab9a07cdb';
  static const String _devAndroid = '5b9f51264457636ab9a07cdc';
  static const String _devIos = '5b9f51264457636ab9a07cdd';
  static const String _devRest = '59b731f084382614ebf72215';
  static const String _devPrivateKey = 'WwDv0UjfwFa04wYG0LJZZv1xwraQnlhnHE375n52X0U=';
  static const String _devClientKey = 'hxS-Up--5RvT6oU6QJE0JA';

  static String _envOrEmpty(String key) {
    try {
      return dotenv.maybeGet(key) ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get env {
    final value = _envOrEmpty('BOOTPAY_ENV');
    return value == 'development' ? 'development' : 'production';
  }

  static bool get isDevelopment => env == 'development';

  static String _resolve(String devKey, String prodKey, String devFallback, String prodFallback) {
    final fromEnv = _envOrEmpty(isDevelopment ? devKey : prodKey);
    if (fromEnv.isNotEmpty) return fromEnv;
    return isDevelopment ? devFallback : prodFallback;
  }

  static String get webApplicationId => _resolve(
        'BOOTPAY_WEB_APPLICATION_ID_DEV',
        'BOOTPAY_WEB_APPLICATION_ID_PROD',
        _devWeb,
        _prodWeb,
      );

  static String get androidApplicationId => _resolve(
        'BOOTPAY_ANDROID_APPLICATION_ID_DEV',
        'BOOTPAY_ANDROID_APPLICATION_ID_PROD',
        _devAndroid,
        _prodAndroid,
      );

  static String get iosApplicationId => _resolve(
        'BOOTPAY_IOS_APPLICATION_ID_DEV',
        'BOOTPAY_IOS_APPLICATION_ID_PROD',
        _devIos,
        _prodIos,
      );

  static String get restApplicationId => _resolve(
        'BOOTPAY_REST_APPLICATION_ID_DEV',
        'BOOTPAY_REST_APPLICATION_ID_PROD',
        _devRest,
        _prodRest,
      );

  static String get privateKey => _resolve(
        'BOOTPAY_PRIVATE_KEY_DEV',
        'BOOTPAY_PRIVATE_KEY_PROD',
        _devPrivateKey,
        _prodPrivateKey,
      );

  static String get clientKey => _resolve(
        'BOOTPAY_CLIENT_KEY_DEV',
        'BOOTPAY_CLIENT_KEY_PROD',
        _devClientKey,
        _prodClientKey,
      );
}
