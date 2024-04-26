class Oopay {
  List<int>? cardQuota = [];

  Oopay({this.cardQuota});

  Map<String, dynamic> toJson() {
    return {
      "card_quota": "[${cardQuota?.join(",")}]"
    };
  }

  Oopay.fromJson(Map<String, dynamic> json) {
    cardQuota = json["card_quota"].cast<int>();
  }
}