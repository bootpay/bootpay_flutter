
import 'dart:convert';

import 'package:bootpay/api/security/bootpay_simple_aes256.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/user_info.dart';
import 'package:http/http.dart' as http;


class ApiProvider {
  get defaultUrl => 'https://analytics.bootpay.co.kr';

  // 회원 추적 코드
  Future<http.Response> userTrace({
    String? id,
    String? email,
    int? gender,
    String? birth,
    String? phone,
    String? area,
    String? applicationId,
    String? ver,
  }) async {

    var payload = {
      "ver": ver ?? '',
      "application_id": applicationId ?? '',
      "id": id ?? '',
      "email": email ?? '',
      "gender": "${gender ?? -1}",
      "birth": birth ?? '',
      "phone": phone ?? '',
      "area": area ?? ''
    };

    var aes256 = BootpaySimpleAES256();
    var data = {
      "data": aes256.strEncode(json.encode(payload)),
      "session_key": aes256.getSessionKey()
    };

    var uri = Uri.parse('$defaultUrl/login');
    return await http.post(
        uri,
        body: data
    );
  }

  // 페이지 추적 코드
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
    String? ver,
  }) async {

    var list = items?.map((e) => e.toJson()).toList();

    var payload = {
      "ver": ver ?? '',
      "application_id": applicationId ?? '',
      "referer": '',
      "sk": await UserInfo.getBootpaySK(),
      "user_id": userId ?? '',
      "url": url ?? '',
      "page_type": pageType ?? 'ios',
      "items": list
    };

    var aes256 = BootpaySimpleAES256();
    var data = {
      "data": aes256.strEncode(json.encode(payload)),
      "session_key": aes256.getSessionKey()
    };

    var uri = Uri.parse('$defaultUrl/call');
    return await http.post(
        uri,
        body: data
    );
  }
}