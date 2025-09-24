import '../extension/json_query_string.dart';

class User {
  String? id = '';
  String? username = '';
  String? email = '';
  int? gender = 0;

  String? birth = '';
  String? phone = '';
  String? area = '';
  String? addr = '';

  User();

  User.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    username = json["username"];
    email = json["email"];
    gender = json["gender"];

    birth = json["birth"];
    phone = json["phone"];
    area = json["area"];
    addr = json["addr"];
  }

  Map<String, dynamic> toJson() => {
    "id": this.id,
    "username": reVal(this.username),
    "email": reVal(this.email),
    "gender": this.gender,
    "birth": this.birth,
    "phone": reVal(this.phone?.replaceAll("-", "")),
    "area": reVal(this.area),
    "addr": reVal(this.addr),
  };

  String toString() {
    List<String> parts = [];

    void addPart(String key, dynamic value) {
      if (value != null) {
        String formattedValue = value is String ? "'${value.queryReplace()}'" : value.toString();
        parts.add("$key: $formattedValue");
      }
    }

    addPart('id', id);
    addPart('username', username);
    addPart('email', email);
    addPart('gender', gender);
    addPart('birth', birth);
    addPart('phone', phone?.replaceAll("-", ""));
    addPart('area', area);
    addPart('addr', addr);

    return "{${parts.join(', ')}}";
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.queryReplace();
    } else {
      return value;
    }
  }
}
