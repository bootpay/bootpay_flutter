

class WidgetData {
  String? pg;
  String? method;
  String? walletId;
  List<WidgetTerm>? selectTerms;
  String? currency; //KRW, USD
  bool? termPassed;
  bool? completed;
  WidgetExtra? extra;

  WidgetData({this.pg, this.method, this.walletId, this.selectTerms, this.currency, this.termPassed, this.completed, this.extra});

  WidgetData.fromJson(Map<String, dynamic> json) {
    pg = json["pg"];
    method = json["method"];
    if (json["select_terms"] != null) {
      selectTerms = [];
      json["select_terms"].forEach((v) {
        selectTerms?.add(WidgetTerm.fromJson(v));
      });
    }
    termPassed = json["term_passed"];
    completed = json["completed"];
    extra = json["extra"] != null ? WidgetExtra.fromJson(json["extra"]) : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'pg': pg,
      'method': method,
      'wallet_id': walletId,
      'currency': currency,
      'term_passed': termPassed,
      'completed': completed,
      'extra': extra?.toJson(),
    };

    if (selectTerms != null) {
      result["select_terms"] = selectTerms?.map((e) => e.toJson()).toList();
    }

    return result;
  }

}

class WidgetTerm {
  String? termId;
  String? pk;
  String? title;
  bool? agree;
  int? termType;

  WidgetTerm({this.termId, this.pk, this.title, this.agree, this.termType});

  WidgetTerm.fromJson(Map<String, dynamic> json) {
    termId = json["term_id"];
    pk = json["pk"];
    title = json["title"];
    agree = json["agree"];
    termType = json["term_type"];
  }

  Map<String, dynamic> toJson() {
    return {
      "term_id": termId,
      "pk": pk,
      "title": title,
      "agree": agree,
      "term_type": termType,
    };
  }

  String toString() {
    List<String> parts = [];

    void addPart(String key, dynamic value) {
      if (value != null) {
        String formattedValue = value is String ? "'${value.replaceAll("'", "\\'")}'" : value.toString();
        parts.add("$key: $formattedValue");
      }
    }

    addPart('term_id', this.termId);
    addPart('pk', this.pk);
    addPart('title', this.title);
    addPart('agree', this.agree);
    addPart('term_type', this.termType);


    return "{${parts.join(',')}}";
  }
}

class WidgetExtra {
  String? directCardCompany;
  int? directCardQuota;
  int? cardQuota;
  // int? directCardQuota;
  // int? cardQuota;

  WidgetExtra({this.directCardCompany, this.directCardQuota, this.cardQuota}) {
    directCardCompany = directCardCompany ?? "-1";
    directCardQuota = directCardQuota ?? 0;
    cardQuota = cardQuota ?? 0;
  }

  WidgetExtra.fromJson(Map<String, dynamic> json) {
    directCardCompany = json["direct_card_company"] ?? "-1";
    directCardQuota = json["direct_card_quota"] ?? 0;
    cardQuota = json["card_quota"] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      "direct_card_company": directCardCompany,
      "direct_card_quota": directCardQuota,
      "card_quota": cardQuota,
    };
  }
}