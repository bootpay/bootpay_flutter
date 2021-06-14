class StatItem {
  String? itemName = '';
  String? itemImg = '';
  String? unique = '';
  String? cat1 = '';
  String? cat2 = '';
  String? cat3 = '';

  StatItem();

  StatItem.fromJson(Map<String, dynamic> json) {
    itemName = json["item_name"];
    itemImg = json["item_img"];
    unique = json["unique"];

    cat1 = json["cat1"];
    cat2 = json["cat2"];
    cat3 = json["cat3"];
  }
}
