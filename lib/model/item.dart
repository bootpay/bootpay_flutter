class Item {
  String? name = '';
  int? qty = 0;
  String? id = '';
  double? price = 0;
  String? cat1 = '';
  String? cat2 = '';
  String? cat3 = '';
  String? categoryType;
  String? categoryCode;
  String? startDate; //시작 - 공연, 영화, 보험, 여행, 항공, 숙박
  String? endDate; //종료일

  Item({
    this.name,
    this.qty,
    this.id,
    this.price,
    this.cat1,
    this.cat2,
    this.cat3,
    this.categoryType,
    this.categoryCode,
    this.startDate,
    this.endDate,
  });

  Item.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    qty = json["qty"];
    id = json["id"];
    price = json["price"];

    cat1 = json["cat1"];
    cat2 = json["cat2"];
    cat3 = json["cat3"];

    categoryType = json["category_type"];
    categoryCode = json["category_code"];
    startDate = json["start_date"];
    endDate = json["end_date"];
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "qty": qty,
    "id": id,
    "price": price,
    "cat1": cat1,
    "cat2": cat2,
    "cat3": cat3,
    "category_type": categoryType,
    "category_code": categoryCode,
    "start_date": startDate,
    "end_date": endDate,
  };

  // Map<String, dynamic> toJson() {
  //   Map<String, dynamic> data = {};
  //
  //   void addMapEntry(String key, dynamic value) {
  //     if (value != null) {
  //       data[key] = value;
  //     }
  //   }
  //
  //   addMapEntry("name", name);
  //   addMapEntry("qty", qty);
  //   addMapEntry("id", id);
  //   addMapEntry("price", price);
  //   addMapEntry("cat1", cat1);
  //   addMapEntry("cat2", cat2);
  //   addMapEntry("cat3", cat3);
  //   addMapEntry("category_type", categoryType);
  //   addMapEntry("category_code", categoryCode);
  //   addMapEntry("start_date", startDate);
  //   addMapEntry("end_date", endDate);
  //
  //   return data;
  // }

  // String toString() {
  //   return "{name: '${reVal(name)}', qty: ${reVal(qty)}, id: '${reVal(id)}', price: ${reVal(price)}, cat1: '${reVal(cat1)}', cat2: '${reVal(cat2)}', cat3: '${reVal(cat3)}'}";
  // }
  String toString() {
    List<String> parts = [];

    void addPart(String key, dynamic value) {
      if (value != null) {
        String formattedValue = value is String ? "'${value.replaceAll("'", "\\'")}'" : value.toString();
        parts.add("$key: $formattedValue");
      }
    }

    addPart('name', name);
    addPart('qty', qty);
    addPart('id', id);
    addPart('price', price);
    addPart('cat1', cat1);
    addPart('cat2', cat2);
    addPart('cat3', cat3);
    addPart('category_type', categoryType);
    addPart('category_code', categoryCode);
    addPart('start_date', startDate);
    addPart('end_date', endDate);

    return "{${parts.join(', ')}}";
  }

  // dynamic reVal(dynamic value) {
  //   if (value is String) {
  //     if (value.isEmpty) {
  //       return '';
  //     }
  //     return value.replaceAll("\"", "'").replaceAll("'", "\\'");
  //   } else {
  //     return value;
  //   }
  // }
}
