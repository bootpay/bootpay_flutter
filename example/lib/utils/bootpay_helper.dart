import 'package:bootpay/bootpay.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

/// Bootpay 관련 설정 및 유틸리티
class BootpayHelper {
  // Application IDs
  static String get webApplicationId {
    return BootpayConfig.ENV == BootpayConfig.ENV_DEBUG
        ? '5b9f51264457636ab9a07cdb'
        : '5b8f6a4d396fa665fdc2b5e7';
  }

  static String get androidApplicationId {
    return BootpayConfig.ENV == BootpayConfig.ENV_DEBUG
        ? '5b9f51264457636ab9a07cdc'
        : '5b8f6a4d396fa665fdc2b5e8';
  }

  static String get iosApplicationId {
    return BootpayConfig.ENV == BootpayConfig.ENV_DEBUG
        ? '5b9f51264457636ab9a07cdd'
        : '5b8f6a4d396fa665fdc2b5e9';
  }

  static String get applicationId {
    return Bootpay().applicationId(
      webApplicationId,
      androidApplicationId,
      iosApplicationId,
    );
  }

  /// 장바구니 아이템을 Bootpay Item으로 변환
  static List<Item> cartToBootpayItems(List<CartItem> cartItems) {
    return cartItems.map((cartItem) {
      final item = Item();
      item.name = cartItem.product.name;
      item.qty = cartItem.quantity;
      item.id = cartItem.product.id;
      item.price = cartItem.product.price;
      item.cat1 = cartItem.product.category;
      item.cat2 = cartItem.product.subCategory;
      return item;
    }).toList();
  }

  /// 기본 Payload 생성
  static Payload createPayload({
    required double price,
    required String orderName,
    List<Item>? items,
    String? pg,
    String? method,
  }) {
    final payload = Payload();

    payload.webApplicationId = webApplicationId;
    payload.androidApplicationId = androidApplicationId;
    payload.iosApplicationId = iosApplicationId;

    payload.price = price;
    payload.orderName = orderName;
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();
    payload.items = items;

    if (pg != null) payload.pg = pg;
    if (method != null) payload.method = method;

    // User 설정
    final user = User();
    user.id = 'user_12345';
    user.username = '홍길동';
    user.email = 'test@bootpay.co.kr';
    user.phone = '01012345678';
    user.area = '서울';
    user.addr = '강남구 역삼동';
    payload.user = user;

    // Extra 설정
    final extra = Extra();
    extra.appScheme = 'bootpayFlutterExampleV2';
    extra.cardQuota = '0,2,3,4,5,6';
    payload.extra = extra;

    // 메타데이터
    payload.metadata = {
      'callbackParam1': 'value12',
      'callbackParam2': 'value34',
    };

    return payload;
  }

  /// 장바구니로부터 Payload 생성
  static Payload createPayloadFromCart(Cart cart) {
    final items = cartToBootpayItems(cart.items);
    return createPayload(
      price: cart.totalPrice,
      orderName: cart.items.length == 1
          ? cart.items.first.product.name
          : '${cart.items.first.product.name} 외 ${cart.items.length - 1}건',
      items: items,
    );
  }
}
