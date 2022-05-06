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
    return "{id: '${reVal(id)}', username: '${reVal(username)}', email: '${reVal(email)}', gender: ${reVal(gender)}, birth: '${reVal(birth)}', phone: '${reVal(phone?.replaceAll("-", ""))}', area: '${reVal(area)}', addr: '${reVal(addr)}'}";
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.replaceAll("\"", "'").replaceAll("'", "\\'");
    } else {
      return value;
    }
  }
}
