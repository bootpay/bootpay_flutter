
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class UserInfo {

  static Future<String> getBootpayUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('uuid') ?? '';
    if(uuid.isEmpty) {
      uuid = Uuid().v1();
      prefs.setString('uuid', uuid);
    }
    return uuid;
  }

  static Future<String> getBootpaySK() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('bootpay_sk') ?? '';
  }

  static setBootpaySK(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bootpay_sk', val);
  }

  static newBootpaySK(String uuid, int time) async {
    await setBootpaySK('${uuid}_${time}');
  }

  static setBootpayLastTime(int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bootpay_last_time', val);
  }

  static getBootpayLastTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bootpay_last_time') ?? 0;
  }

  static Future<String> getBootpayUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('bootpay_user_id') ?? '';
  }

  static setBootpayUserId(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bootpay_user_id', val);
  }

  static updateInfo() async {
    final uuid = await getBootpayUUID();
    final bootpaySK = await getBootpaySK();
    final int lastTime = await getBootpayLastTime();

    int current = DateTime.now().millisecondsSinceEpoch;
    if(bootpaySK == '') await newBootpaySK(uuid, current);

    bool isExpired = current - lastTime > 30 * 60 * 1000;
    if(isExpired) await newBootpaySK(uuid, current);
    await setBootpayLastTime(current);
  }
}