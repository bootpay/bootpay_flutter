import 'dart:convert';

import 'commerce_user.dart';
import 'commerce_product.dart';
import 'commerce_extra.dart';

/// Commerce 결제 요청용 페이로드 모델
class CommercePayload {
  /// 클라이언트 키 (Commerce 대시보드에서 발급)
  String clientKey;

  /// 청구서/주문 이름
  String? name;

  /// 메모
  String? memo;

  /// 사용자 정보
  CommerceUser? user;

  /// 결제 금액
  double price;

  /// 결제 완료 후 리다이렉트 URL
  String? redirectUrl;

  /// 사용량 API URL (구독 결제 시)
  String? usageApiUrl;

  /// 자동 로그인 사용 여부
  bool useAutoLogin;

  /// 요청 ID (주문 ID)
  String? requestId;

  /// 알림 사용 여부
  bool useNotification;

  /// 상품 목록
  List<CommerceProduct>? products;

  /// 메타데이터 (추가 정보)
  Map<String, String>? metadata;

  /// 추가 옵션
  CommerceExtra? extra;

  CommercePayload({
    this.clientKey = '',
    this.name,
    this.memo,
    this.user,
    this.price = 0,
    this.redirectUrl,
    this.usageApiUrl,
    this.useAutoLogin = false,
    this.requestId,
    this.useNotification = false,
    this.products,
    this.metadata,
    this.extra,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dict = {};

    dict['client_key'] = clientKey;
    if (name != null) dict['name'] = name;
    if (memo != null) dict['memo'] = memo;
    if (user != null) dict['user'] = user!.toJson();
    if (price > 0) dict['price'] = price;
    if (redirectUrl != null) dict['redirect_url'] = redirectUrl;
    if (usageApiUrl != null) dict['usage_api_url'] = usageApiUrl;
    dict['use_auto_login'] = useAutoLogin;
    if (requestId != null) dict['request_id'] = requestId;
    dict['use_notification'] = useNotification;

    if (products != null && products!.isNotEmpty) {
      dict['products'] = products!.map((p) => p.toJson()).toList();
    }

    if (metadata != null && metadata!.isNotEmpty) {
      dict['metadata'] = metadata;
    }

    if (extra != null) dict['extra'] = extra!.toJson();

    return dict;
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  factory CommercePayload.fromJson(Map<String, dynamic> json) {
    return CommercePayload(
      clientKey: json['client_key'] ?? '',
      name: json['name'],
      memo: json['memo'],
      user: json['user'] != null ? CommerceUser.fromJson(json['user']) : null,
      price: (json['price'] ?? 0).toDouble(),
      redirectUrl: json['redirect_url'],
      usageApiUrl: json['usage_api_url'],
      useAutoLogin: json['use_auto_login'] ?? false,
      requestId: json['request_id'],
      useNotification: json['use_notification'] ?? false,
      products: json['products'] != null
          ? (json['products'] as List)
              .map((p) => CommerceProduct.fromJson(p))
              .toList()
          : null,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'])
          : null,
      extra:
          json['extra'] != null ? CommerceExtra.fromJson(json['extra']) : null,
    );
  }

  @override
  String toString() {
    return toJsonString();
  }
}
