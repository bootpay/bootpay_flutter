import 'package:flutter/foundation.dart';
import 'cart_item.dart';
import 'product.dart';

/// 장바구니 상태 관리 (싱글톤)
class Cart extends ChangeNotifier {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// 상품 추가
  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// 상품 수량 업데이트
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// 상품 제거
  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// 장바구니 비우기
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// 특정 상품이 장바구니에 있는지 확인
  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// 특정 상품의 수량 가져오기
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(id: '', name: '', description: '', price: 0, imageUrl: '')),
    );
    return item.quantity;
  }
}
