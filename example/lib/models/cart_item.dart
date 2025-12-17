import 'product.dart';

/// 장바구니 아이템 모델
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// 해당 아이템의 총 가격
  double get totalPrice => product.price * quantity;
}
