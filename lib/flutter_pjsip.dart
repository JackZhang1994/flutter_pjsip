import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPjsip {
  static const MethodChannel _channel = const MethodChannel('flutter_pjsip');

  static Future<bool> pjsipInit() async {
    return await _channel.invokeMethod('method_pjsip_init');
  }

  static Future<bool> pjsipLogin({String username, String password, String ip, String port}) async {
    Map<String, String> map = {"username": username, "password": password, "ip": ip, "port": port};
    return await _channel.invokeMethod("method_pjsip_login", map);
  }

  static Future<void> pjsipCall({String username, String ip, String port}) async {
    Map<String, String> map = {"username": username, "ip": ip, "port": port};
    return await _channel.invokeMethod("method_pjsip_call", map);
  }

  static Future<bool> pjsipLogout() async {
    return await _channel.invokeMethod('method_pjsip_logout');
  }

  static Future<bool> pjsipDeinit() async {
    return await _channel.invokeMethod('method_pjsip_deinit');
  }
}
