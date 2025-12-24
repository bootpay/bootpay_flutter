import 'dart:convert';

/// Commerce 사용자 정보 모델
class CommerceUser {
  /// 회원 타입 (guest, member 등)
  String membershipType;

  /// 사용자 ID
  String? userId;

  /// 사용자 이름
  String? name;

  /// 전화번호
  String? phone;

  /// 이메일
  String? email;

  CommerceUser({
    this.membershipType = 'guest',
    this.userId,
    this.name,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dict = {};
    dict['membership_type'] = membershipType;
    if (userId != null) dict['user_id'] = userId;
    if (name != null) dict['name'] = name;
    if (phone != null) dict['phone'] = phone;
    if (email != null) dict['email'] = email;
    return dict;
  }

  factory CommerceUser.fromJson(Map<String, dynamic> json) {
    return CommerceUser(
      membershipType: json['membership_type'] ?? 'guest',
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
