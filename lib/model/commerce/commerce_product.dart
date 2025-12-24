import 'dart:convert';

/// Commerce 상품 모델
class CommerceProduct {
  /// 상품 ID (Commerce 대시보드에서 생성된 ID)
  String productId;

  /// 구독 기간 (-1: 무기한)
  int duration;

  /// 수량
  int quantity;

  CommerceProduct({
    this.productId = '',
    this.duration = -1,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'duration': duration,
      'quantity': quantity,
    };
  }

  factory CommerceProduct.fromJson(Map<String, dynamic> json) {
    return CommerceProduct(
      productId: json['product_id'] ?? '',
      duration: json['duration'] ?? -1,
      quantity: json['quantity'] ?? 1,
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
