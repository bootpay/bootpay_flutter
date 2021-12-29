class Item {
  String? name = '';
  int? qty = 0;
  String? id = '';
  double? price = 0;
  String? cat1 = '';
  String? cat2 = '';
  String? cat3 = '';

  Item();

  Item.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    qty = json["qty"];
    id = json["id"];
    price = json["price"];

    cat1 = json["cat1"];
    cat2 = json["cat2"];
    cat3 = json["cat3"];
  }

  Map<String, dynamic> toJson() => {
        "name": reVal(this.name),
        "qty": reVal(this.qty),
        "id": reVal(this.id),
        "price": reVal(this.price),
        "cat1": reVal(this.cat1),
        "cat2": reVal(this.cat2),
        "cat3": reVal(this.cat3),
  };

  String toString() {
    return "{name: '${reVal(name)}', qty: ${reVal(qty)}, id: '${reVal(id)}', price: ${reVal(price)}, cat1: '${reVal(cat1)}', cat2: '${reVal(cat2)}', cat3: '${reVal(cat3)}'}";
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
