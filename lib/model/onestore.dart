class Onestore {
  String? adId = "UNKNOWN_ADID";
  String? simOperator = "UNKNOWN_SIM_OPERATOR";
  String? installerPackageName = "UNKNOWN_INSTALLER";

  Onestore();

  Onestore.fromJson(Map<String, dynamic> json) {
    adId = json["ad_id"];
    simOperator = json["sim_operator"];
    installerPackageName = json["installer_package_name"];
  }
}
