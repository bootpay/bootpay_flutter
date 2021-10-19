

import 'package:bootpay/api/api_provider.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:http/http.dart' as http;


class BootpayAnalytics {

  // 회원 추적 코드
  static Future<http.Response> userTrace({
    String? id,
    String? email,
    int? gender,
    String? birth,
    String? phone,
    String? area,
    String? applicationId,
  }) async {
    var provider = ApiProvider();
    return provider.userTrace(
      id: id,
      email: email,
      gender: gender,
      birth: birth,
      phone: phone,
      area: area,
      applicationId: applicationId
    );
  }

  // 페이지 추적 코드
  static Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
  }) async {
    var provider = ApiProvider();

    return provider.pageTrace(
      url: url,
      pageType: pageType,
      applicationId: applicationId,
      userId: userId,
      items: items
    );
  }
}