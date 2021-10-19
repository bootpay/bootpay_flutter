
import 'dart:convert';

import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/user_info.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';


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
  }) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var payload = {
      "ver": packageInfo.version,
      "application_id": applicationId ?? '',
      "id": id ?? '',
      "email": email ?? '',
      "gender": "${gender ?? -1}",
      "birth": birth ?? '',
      "phone": phone ?? '',
      "area": area ?? ''
    };

    var uri = Uri.parse('$defaultUrl/login');
    return await http.post(
        uri,
        body: payload
    );
  }

  // 페이지 추적 코드
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
  }) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    print(1234);
    var list = items?.map((e) => e.toJson()).toList();

    print(jsonEncode(list ?? []));

    var payload = {
      "ver": packageInfo.version,
      "application_id": applicationId ?? '',
      "referer": '',
      "sk": await UserInfo.getBootpaySK(),
      "user_id": userId ?? '',
      "url": url ?? '',
      "page_type": pageType ?? 'ios',
      "items": jsonEncode(list ?? [])
    };

    var uri = Uri.parse('$defaultUrl/login');
    return await http.post(
        uri,
        body: payload
    );
  }
}