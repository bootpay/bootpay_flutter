

class SelectedInfo {
  String? pg;
  String? method;
  List<SelectedInfoTerm>? selectedTerms;
  bool? termPassed;
  bool? completed;
  SelectedInfoExtra? extra;

  SelectedInfo({this.pg, this.method, this.selectedTerms, this.termPassed, this.completed, this.extra});

  SelectedInfo.fromJson(Map<String, dynamic> json) {
    pg = json["pg"];
    method = json["method"];
    if (json["selected_terms"] != null) {
      selectedTerms = [];
      json["selected_terms"].forEach((v) {
        selectedTerms?.add(SelectedInfoTerm.fromJson(v));
      });
    }
    termPassed = json["term_passed"];
    completed = json["completed"];
    extra = json["extra"] != null ? SelectedInfoExtra.fromJson(json["extra"]) : null;
  }

}

class SelectedInfoTerm {
  String? termId;
  String? pk;
  String? title;
  String? agree;
  int? termType;

  SelectedInfoTerm({this.termId, this.pk, this.title, this.agree, this.termType});

  SelectedInfoTerm.fromJson(Map<String, dynamic> json) {
    termId = json["term_id"];
    pk = json["pk"];
    title = json["title"];
    agree = json["agree"];
    termType = json["term_type"];
  }
}

class SelectedInfoExtra {
  String? directCardCompany;
  int? directCardQuota;
  int? cardQuota;
  // int? directCardQuota;
  // int? cardQuota;

  SelectedInfoExtra({this.directCardCompany, this.directCardQuota, this.cardQuota}) {
    directCardCompany = directCardCompany ?? "-1";
    directCardQuota = directCardQuota ?? 0;
    cardQuota = cardQuota ?? 0;
  }

  SelectedInfoExtra.fromJson(Map<String, dynamic> json) {
    directCardCompany = json["direct_card_company"] ?? "-1";
    directCardQuota = json["direct_card_quota"] ?? 0;
    cardQuota = json["card_quota"] ?? 0;
  }
}