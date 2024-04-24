class SelectedInfo {
  String? pg;
  String? method;
  List<SelectedInfoTerms>? selectedTerms;
  bool? termPassed;
  SelectedInfoExtra? extra;

  SelectedInfo({this.pg, this.method, this.selectedTerms, this.termPassed, this.extra});

  SelectedInfo.fromJson(Map<String, dynamic> json) {
    pg = json["pg"];
    method = json["method"];
    if (json["selected_terms"] != null) {
      selectedTerms = [];
      json["selected_terms"].forEach((v) {
        selectedTerms?.add(SelectedInfoTerms.fromJson(v));
      });
    }
    termPassed = json["term_passed"];
    extra = json["extra"] != null ? SelectedInfoExtra.fromJson(json["extra"]) : null;
  }

}

class SelectedInfoTerms {
  String? termId;
  String? pk;
  String? title;
  String? agree;
  int? termType;

  SelectedInfoTerms({this.termId, this.pk, this.title, this.agree, this.termType});

  SelectedInfoTerms.fromJson(Map<String, dynamic> json) {
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

  SelectedInfoExtra({this.directCardCompany, this.directCardQuota, this.cardQuota});

  SelectedInfoExtra.fromJson(Map<String, dynamic> json) {
    directCardCompany = json["direct_card_company"] ?? "-1";
    directCardQuota = json["direct_card_quota"] ?? 0;
    cardQuota = json["card_quota"] ?? 0;
  }
}