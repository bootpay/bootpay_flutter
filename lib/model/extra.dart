class Extra {

  String? cardQuota = ''; //할부허용 범위 (5만원 이상 구매시)
  String? sellerName = '';  //노출되는 판매자명 설정
  int? deliveryDay = 1; //배송일자
  String? locale = 'ko'; //결제창 언어지원
  String? offerPeriod; //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
  bool? displayCashReceipt = true; // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
  String? depositExpiration = ""; //가상계좌 입금 만료일자 설정
  String? appScheme;  //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
  bool? useCardPoint = true; //카드 포인트 사용 여부 (토스만 가능)
  String? directCard = ""; //해당 카드로 바로 결제창 (토스만 가능)
  bool? useOrderId = false; //가맹점 order_id로 PG로 전송
  bool? internationalCardOnly = false; //해외 결제카드 선택 여부 (토스만 가능)
  String? phoneCarrier = ""; // //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
  String? directAppCard = ""; //카드사앱으로 direct 호출
  String? directSamsungpay = ""; //삼성페이 바로 띄우기
  bool? testDeposit = false; //가상계좌 모의 입금
  bool? popup = false;  //네이버페이 등 특정 PG 일 경우 popup을 true로 해야함
  bool? separatelyConfirmed = true; // confirm 이벤트를 호출할지 말지, false일 경우 자동승인

  Extra();

  Extra.fromJson(Map<String, dynamic> json) {
    cardQuota = json["card_quota"];
    sellerName = json["seller_name"];

    deliveryDay = json["delivery_day"];
    locale = json["locale"];
    offerPeriod = json["offer_period"];

    displayCashReceipt = json["display_cash_receipt"];
    depositExpiration = json["deposit_expiration"];
    appScheme = json["app_scheme"];

    useCardPoint = json["use_card_point"];
    directCard = json["direct_card"];
    useOrderId = json["use_order_id"];
    internationalCardOnly = json["international_card_only"];
    phoneCarrier = json["phone_carrier"];
    directAppCard = json["direct_app_card"];
    directSamsungpay = json["direct_samsungpay"];
    testDeposit = json["test_deposit"];
    popup = json["popup"];
    separatelyConfirmed = json["separately_confirmed"];
  }

  Map<String, dynamic> toJson() => {
    "card_quota": this.cardQuota,
    "seller_name": this.sellerName,
    "delivery_day": this.deliveryDay,
    "locale": this.locale,
    "offer_period": this.offerPeriod,
    "display_cash_receipt": this.displayCashReceipt,
    "deposit_expiration": this.depositExpiration,
    "app_scheme": this.appScheme,
    "use_card_point": this.useCardPoint,
    "direct_card": this.directCard,
    "use_order_id": this.useOrderId,
    "international_card_only": this.internationalCardOnly,
    "phone_carrier": this.phoneCarrier,
    "direct_app_card": this.directAppCard,
    "direct_samsungpay": this.directSamsungpay,
    "test_deposit": this.testDeposit,
    "popup": this.popup,
    "separately_confirmed": this.separatelyConfirmed,
  };

  // String getQuotas() {
  //   if (quotas == null || quotas!.isEmpty) return '';
  //   String result = '';
  //   for (int quota in  quotas!) {
  //     if (result.length > 0) result += ',';
  //     result += quota.toString();
  //   }
  //   return result;
  // }

  String toString() {
    return "{card_quota: '${reVal(cardQuota)}', seller_name: '${reVal(sellerName)}', delivery_day: ${reVal(deliveryDay)}, locale: '${reVal(locale)}'," +
        "offer_period: '${reVal(offerPeriod)}', display_cash_receipt: '${reVal(displayCashReceipt)}', deposit_expiration: '${reVal(depositExpiration)}'," +
        "app_scheme: '${reVal(appScheme)}', use_card_point: ${useCardPoint}, direct_card: '${reVal(directCard)}', use_order_id: ${useOrderId}, international_card_only: ${internationalCardOnly}," +
        "phone_carrier: '${reVal(phoneCarrier)}', direct_app_card: '${reVal(directAppCard)}', direct_samsungpay: '${reVal(directSamsungpay)}', test_deposit: ${reVal(testDeposit)}, popup: ${popup}, separately_confirmed: ${separatelyConfirmed} }";
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.replaceAll("\"", "'").replaceAll("'", "\\'");
    } else {
      return value.toString();
    }
  }
}
