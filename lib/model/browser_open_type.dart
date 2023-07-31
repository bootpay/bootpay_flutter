class BrowserOpenType {

  String? browser = '';
  String? openType = '';

  BrowserOpenType();

  BrowserOpenType.fromJson(Map<String, dynamic> json) {
    browser = json["browser"];
    openType = json["open_type"];
  }

  Map<String, dynamic> toJson() => {
    "browser": this.browser,
    "open_type": this.openType,
  };

  String toString() {
    return "{browser: '$browser', open_type: '$openType'}";
  }
}
