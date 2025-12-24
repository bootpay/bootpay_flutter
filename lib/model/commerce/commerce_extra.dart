import 'dart:convert';

/// Commerce 추가 옵션 모델
class CommerceExtra {
  /// 분리 확인 여부 (기본값: false)
  bool separatelyConfirmed;

  /// 즉시 주문 생성 여부 (기본값: true)
  bool createOrderImmediately;

  CommerceExtra({
    this.separatelyConfirmed = false,
    this.createOrderImmediately = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'separately_confirmed': separatelyConfirmed,
      'create_order_immediately': createOrderImmediately,
    };
  }

  factory CommerceExtra.fromJson(Map<String, dynamic> json) {
    return CommerceExtra(
      separatelyConfirmed: json['separately_confirmed'] ?? false,
      createOrderImmediately: json['create_order_immediately'] ?? true,
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
