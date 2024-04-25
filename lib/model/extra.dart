import 'package:bootpay/model/browser_open_type.dart';

import 'extra_card_easy_option.dart';

class Extra {

  String? cardQuota = ''; //할부허용 범위 (5만원 이상 구매시)
  String? sellerName = '';  //노출되는 판매자명 설정
  int? deliveryDay = 1; //배송일자
  String? locale = 'ko'; //결제창 언어지원
  String? offerPeriod = ''; //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨, 네이버페이 - 비쇼핑 기준 이용완료일 (정산시 필요)
  bool? displayCashReceipt = true; // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
  String? depositExpiration = ""; //가상계좌 입금 만료일자 설정
  String? appScheme;  //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
  bool? useCardPoint = false; //카드 포인트 사용 여부 (토스만 가능)
  String? directCardCompany = ""; //해당 카드로 바로 결제창
  String? directCardQuota = ""; //다이렉트 카드시 할부 정보는 필수 00, 02, 03


  bool? useOrderId = false; //가맹점 order_id로 PG로 전송
  bool? internationalCardOnly = false; //해외 결제카드 선택 여부 (토스만 가능)
  String? phoneCarrier = ""; // //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
  // bool? directAppCard = false; //카드사앱으로 direct 호출
  bool? directSamsungpay = false; //삼성페이 바로 띄우기
  bool? testDeposit = false; //가상계좌 모의 입금
  bool? enableErrorWebhook = false; //결제 오류시 Feedback URL로 webhook
  bool? separatelyConfirmed = true; // confirm 이벤트를 호출할지 말지, false일 경우 자동승인
  bool? confirmOnlyRestApi = false; // REST API로만 승인 처리
  String? openType = 'redirect'; //페이지 오픈 type, [iframe, popup, redirect] 중 택 1
  bool? useBootpayInappSdk = true; //native app에서는 redirect를 완성도있게 지원하기 위한 옵션
  String? redirectUrl = 'https://api.bootpay.co.kr/v2'; //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
  bool? displaySuccessResult = false; // 결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
  bool? displayErrorResult = true; // 결제 실패되면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
  bool? subscribeTestPayment = true; //100원 결제 후 취소
  // double? disposableCupDeposit = 0; // 배달대행 플랫폼을 위한 컵 보증급 가격
  ExtraCardEasyOption cardEasyOption = ExtraCardEasyOption();
  List<BrowserOpenType>? browserOpenType = [];
  int? useWelcomepayment = 0; //웰컴 재판모듈 진행시 1
  String? firstSubscriptionComment = ""; // 자동결제 price > 0 조건일 때 첫 결제 관련 메세지
  List<String>? enableCardCompanies = []; // https://developers.nicepay.co.kr/manual-code-partner.php '01,02,03,04,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,39,40,41,42'
  List<String>? exceptCardCompanies = []; // 제외할 카드사 리스트 ( enable_card_companies가 우선순위를 갖는다 )
  List<String>? enableEasyPayments = []; // 노출될 간편결제 리스트
  int? confirmGraceSeconds = 10; // 결제승인 유예시간 ( 승인 요청을 여러번하더라도 승인 이후 특정 시간동안 계속해서 결제 response_data 를 리턴한다 )
  int? ageLimit = 0;
  bool? escrow = false;
  bool? showCloseButton = false;

  int? timeout = 30;
  bool? commonEventWebhook = false; //창닫기, 결제만료 웹훅 추가

  double? deliveryPrice = 0; //배송료, 상품이 과세면 배송료도 과세, 면세면 배송료도 면세
  bool? useExtraDeduction = false; //문화비 소득 공제 대상 가맹점은 true

  bool? directCardInterest = false; //무이자여부, true면 무이자

  Extra({
    this.cardQuota,
    this.sellerName,
    this.deliveryDay,
    this.locale,
    this.offerPeriod,
    this.displayCashReceipt,
    this.depositExpiration,
    this.appScheme,
    this.useCardPoint,
    this.directCardCompany,
    this.directCardQuota,
    this.useOrderId,
    this.internationalCardOnly,
    this.phoneCarrier,
    this.directSamsungpay,
    this.testDeposit,
    this.enableErrorWebhook,
    this.separatelyConfirmed,
    this.confirmOnlyRestApi,
    this.openType,
    this.useBootpayInappSdk,
    this.redirectUrl,
    this.displaySuccessResult,
    this.displayErrorResult,
    this.subscribeTestPayment,
    // this.disposableCupDeposit,
    this.browserOpenType,
    this.useWelcomepayment,
    this.firstSubscriptionComment,
    this.enableCardCompanies,
    this.exceptCardCompanies,
    this.enableEasyPayments,
    this.confirmGraceSeconds,
    this.ageLimit,
    this.escrow,
    this.showCloseButton,
    this.timeout,
    this.commonEventWebhook,
    this.deliveryPrice,
    this.useExtraDeduction,
  }) {
    this.deliveryDay = this.deliveryDay ?? 1;
    this.displayCashReceipt = this.displayCashReceipt ?? true;
    this.separatelyConfirmed = this.separatelyConfirmed ?? true;
    this.locale = this.locale ?? 'ko';
    this.openType = this.openType ?? 'redirect';
    this.useBootpayInappSdk = this.useBootpayInappSdk ?? true;
    this.redirectUrl = this.redirectUrl ?? 'https://api.bootpay.co.kr/v2';
    this.displayErrorResult = this.displayErrorResult ?? true;
    this.subscribeTestPayment = this.subscribeTestPayment ?? true;
    this.confirmGraceSeconds = this.confirmGraceSeconds ?? 10;
    this.timeout = this.timeout ?? 30;
  }

  Extra.fromJson(Map<String, dynamic> json) {
    List<String> enableCardCompanies = [];
    if(json['enableCardCompanies'] is List<dynamic>) {
      enableCardCompanies = List<String>.from(json['enableCardCompanies']);
    }

    List<String> exceptCardCompanies = [];
    if(json['exceptCardCompanies'] is List<dynamic>) {
      exceptCardCompanies = List<String>.from(json['exceptCardCompanies']);
    }

    List<String> enableEasyPayments = [];
    if(json['enableEasyPayments'] is List<dynamic>) {
      enableEasyPayments = List<String>.from(json['enableEasyPayments']);
    }

    cardQuota = json["card_quota"];
    sellerName = json["seller_name"];

    deliveryDay = json["delivery_day"];
    locale = json["locale"];
    offerPeriod = json["offer_period"];

    displayCashReceipt = json["display_cash_receipt"];
    depositExpiration = json["deposit_expiration"];
    appScheme = json["app_scheme"];

    useCardPoint = json["use_card_point"];
    directCardCompany = json["direct_card_company"];
    useOrderId = json["use_order_id"];
    internationalCardOnly = json["international_card_only"];
    phoneCarrier = json["phone_carrier"];
    directSamsungpay = json["direct_samsungpay"];
    testDeposit = json["test_deposit"];
    enableErrorWebhook = json["enable_error_webhook"];
    separatelyConfirmed = json["separately_confirmed"];
    confirmOnlyRestApi = json["confirm_only_rest_api"];
    openType = json["open_type"];
    useBootpayInappSdk = json["use_bootpay_inapp_sdk"];
    redirectUrl = json["redirect_url"];
    displaySuccessResult = json["display_success_result"];
    displayErrorResult = json["display_error_result"];
    // disposableCupDeposit = json["disposable_cup_deposit"];
    useWelcomepayment = json["use_welcomepayment"];
    firstSubscriptionComment = json["first_subscription_comment"];
    this.enableCardCompanies = enableCardCompanies;
    this.exceptCardCompanies = exceptCardCompanies;
    this.enableEasyPayments = enableEasyPayments;
    confirmGraceSeconds = json["confirm_grace_seconds"];
    ageLimit = json["age_limit"];
    subscribeTestPayment = json["subscribe_test_payment"];
    timeout = json["timeout"];
    escrow = json["escrow"];
    showCloseButton = json["show_close_button"];
    commonEventWebhook = json["common_event_webhook"];
    deliveryPrice = json["delivery_price"];
    useExtraDeduction = json["use_extra_deduction"];
    directCardInterest = json["direct_card_interest"];
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
    "direct_card_company": this.directCardCompany,
    "direct_card_quota": this.directCardQuota,
    "use_order_id": this.useOrderId,
    "international_card_only": this.internationalCardOnly,
    "phone_carrier": this.phoneCarrier,
    "direct_samsungpay": this.directSamsungpay,
    "test_deposit": this.testDeposit,
    "enable_error_webhook": this.enableErrorWebhook,
    "separately_confirmed": this.separatelyConfirmed,
    "confirm_only_rest_api": this.confirmOnlyRestApi,
    "open_type": this.openType,
    "use_bootpay_inapp_sdk": this.useBootpayInappSdk,
    "redirect_url": this.redirectUrl,
    "display_success_result": this.displaySuccessResult,
    "display_error_result": this.displayErrorResult,
    // "disposable_cup_deposit": this.disposableCupDeposit,
    "use_welcomepayment": this.useWelcomepayment,
    "first_subscription_comment": this.firstSubscriptionComment,
    "except_card_companies": this.exceptCardCompanies,
    "browser_open_type": this.browserOpenType,
    "enable_easy_payments": this.enableEasyPayments,
    "confirm_grace_seconds": this.confirmGraceSeconds,
    "age_limit": this.ageLimit,
    "subscribe_test_payment": this.subscribeTestPayment,
    "timeout": this.timeout,
    "escrow": this.escrow,
    "show_close_button": this.showCloseButton,
    "common_event_webhook": this.commonEventWebhook,
    "delivery_price": this.deliveryPrice,
    "use_extra_deduction": this.useExtraDeduction,
    "direct_card_interest": this.directCardInterest
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

    List<String> parts = [];

    void addPart(String key, dynamic value) {
      if (value != null) {
        String formattedValue = value is String ? "'${value.replaceAll("'", "\\'")}'" : value.toString();
        parts.add("$key: $formattedValue");
      }
    }

    void addPartList(String key, List<dynamic>? value) {
      if (value == null) return;
      if (value.isEmpty) return;
      if (value is List<String>) {
        String formattedValue = value.map((e) => "'$e'").join(",");
        parts.add("$key: [$formattedValue]");
      } else if (value is List<BrowserOpenType>) {
        String formattedValue = value.map((e) => e.toString()).join(",");
        parts.add("$key: [$formattedValue]");
      }
    }

    addPart('card_quota', cardQuota ?? '0');
    addPart('seller_name', sellerName);
    addPart('delivery_day', deliveryDay);
    addPart('locale', locale);
    addPart('offer_period', offerPeriod);
    addPart('display_cash_receipt', displayCashReceipt);
    addPart('deposit_expiration', depositExpiration);
    addPart('app_scheme', appScheme);
    addPart('use_card_point', useCardPoint);
    addPart('direct_card_company', directCardCompany);
    addPart('direct_card_quota', directCardQuota ?? '0');
    addPart('use_order_id', useOrderId);
    addPart('international_card_only', internationalCardOnly);
    addPart('phone_carrier', phoneCarrier);

    addPart('direct_samsungpay', directSamsungpay);
    addPart('test_deposit', testDeposit);
    addPart('enable_error_webhook', enableErrorWebhook);
    addPart('separately_confirmed', separatelyConfirmed);
    addPart('confirm_only_rest_api', confirmOnlyRestApi);
    addPart('open_type', openType);
    addPart('use_bootpay_inapp_sdk', useBootpayInappSdk);
    addPart('redirect_url', redirectUrl);
    addPart('display_success_result', displaySuccessResult);
    addPart('display_error_result', displayErrorResult);
    // addPart('disposable_cup_deposit', disposableCupDeposit);
    addPart('use_welcomepayment', useWelcomepayment);
    addPart('first_subscription_comment', firstSubscriptionComment);

    addPartList('browser_open_type', browserOpenType);
    addPartList('enable_card_companies', enableCardCompanies);
    addPartList('enable_easy_payments', enableEasyPayments);
    addPartList('except_card_companies', exceptCardCompanies);



    addPart('confirm_grace_seconds', confirmGraceSeconds);
    addPart('age_limit', ageLimit);
    addPart('subscribe_test_payment', subscribeTestPayment);
    addPart('timeout', timeout);
    addPart('escrow', escrow);
    addPart('show_close_button', showCloseButton);
    addPart('common_event_webhook', commonEventWebhook);
    addPart('delivery_price', deliveryPrice);
    addPart('use_extra_deduction', useExtraDeduction);
    addPart('direct_card_interest', directCardInterest);

    return "{${parts.join(',')}}";
  }


  // String toString() {
  //   return "{card_quota: '${reVal(cardQuota)}', seller_name: '${reVal(sellerName)}', delivery_day: ${reVal(deliveryDay)}, locale: '${reVal(locale)}', escrow: ${escrow}," +
  //       "offer_period: '${reVal(offerPeriod)}', display_cash_receipt: '${reVal(displayCashReceipt)}', deposit_expiration: '${reVal(depositExpiration)}', show_close_button: ${showCloseButton}," +
  //       "app_scheme: '${reVal(appScheme)}', use_card_point: ${useCardPoint}, direct_card_company: '${reVal(directCardCompany)}',direct_card_quota: '${reVal(directCardQuota)}',  use_order_id: ${useOrderId}, international_card_only: ${internationalCardOnly}," +
  //       "phone_carrier: '${reVal(phoneCarrier)}', direct_samsungpay: ${directSamsungpay}, test_deposit: ${reVal(testDeposit)}, enable_error_webhook: ${enableErrorWebhook}, separately_confirmed: ${separatelyConfirmed}," +
  //       "confirm_only_rest_api: ${confirmOnlyRestApi}, open_type: '${reVal(openType)}', redirect_url: '${reVal(redirectUrl)}', display_success_result: ${displaySuccessResult}, display_error_result: ${displayErrorResult}, disposable_cup_deposit: ${disposableCupDeposit}," +
  //       "first_subscription_comment: '${reVal(firstSubscriptionComment)}', browser_open_type: [${(browserOpenType ?? []).map((obj) => obj.toString()).join(',')}], enable_card_companies: [${(enableCardCompanies ?? []).map((e) => "\'$e\'").join(",")}], except_card_companies: [${(exceptCardCompanies ?? []).map((e) => "\'$e\'").join(",")}], enable_easy_payments: [${(enableEasyPayments ?? []).map((e) => "\'$e\'").join(",")}], confirm_grace_seconds: ${confirmGraceSeconds}," +
  //       "use_bootpay_inapp_sdk: ${useBootpayInappSdk}, use_welcomepayment: ${useWelcomepayment}, first_subscription_comment: '${reVal(firstSubscriptionComment)}', age_limit: '${reVal(ageLimit)}', subscribe_test_payment: ${subscribeTestPayment}, timeout: $timeout, common_event_webhook: ${commonEventWebhook} }";
  // }
  //
  // dynamic reVal(dynamic value) {
  //   if (value is String) {
  //     if (value.isEmpty) {
  //       return '';
  //     }
  //     return value.replaceAll("\"", "'").replaceAll("'", "\\'");
  //   } else {
  //     return value.toString();
  //   }
  // }
}
