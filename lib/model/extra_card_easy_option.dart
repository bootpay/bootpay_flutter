class ExtraCardEasyOption {
  String? title = '';

  ExtraCardEasyOption();

  ExtraCardEasyOption.fromJson(Map<String, dynamic> json) {
    title = json["title"];
  }

  Map<String, dynamic> toJson() => {
    "title": this.title,
  };  
}
