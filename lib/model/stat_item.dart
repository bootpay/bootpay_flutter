class StatItem {
  String? itemName = '';
  String? itemImg = '';
  String? unique = '';
  double? price = 0;
  String? cat1 = '';
  String? cat2 = '';
  String? cat3 = '';

  StatItem();

  StatItem.fromJson(Map<String, dynamic> json) {
    itemName = json["item_name"];
    itemImg = json["item_img"];
    unique = json["unique"];
    price = json['price'];

    cat1 = json["cat1"];
    cat2 = json["cat2"];
    cat3 = json["cat3"];
  }

  Map toJson() => {
    'itemName': itemName,
    'itemImg': itemImg,
    'unique': unique,
    'price': price,
    'cat1': cat1,
    'cat2': cat2,
    'cat3': cat3,
  };
}
 