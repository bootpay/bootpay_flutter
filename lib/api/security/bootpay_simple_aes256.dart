
import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';

class BootpaySimpleAES256 {
  String key = "";
  String iv = "";

  BootpaySimpleAES256() {
    this.key = getRandomKey(32);
    this.iv = getRandomKey(16);


  }

  Random _rnd = Random();

  String getRandomKey(int length) {
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return String.fromCharCodes(
        Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))
        )
    );
  }

  String getSessionKey() {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return "${ stringToBase64.encode(this.key)}##${ stringToBase64.encode(this.iv)}";
  }

  String strEncode(String str) {
    final keyValue = Key.fromUtf8(key);
    final ivValue = IV.fromUtf8(iv);

    final encrypter = Encrypter(AES(keyValue, mode: AESMode.cbc));
    final res = encrypter.encrypt(str, iv: ivValue);

    // print('str: $str\nkey: ${this.key}\niv: ${this.iv}\nsession_key: ${getSessionKey()}\ndata: ${res.base64}');

    return res.base64;
  }
}