import 'dart:async';

import 'package:flutter/services.dart';

enum SipCallState {
  PJSIP_INV_STATE_NULL,
  PJSIP_INV_STATE_CALLING,
  PJSIP_INV_STATE_INCOMING,
  PJSIP_INV_STATE_EARLY,
  PJSIP_INV_STATE_CONNECTING,
  PJSIP_INV_STATE_CONFIRMED,
  PJSIP_INV_STATE_DISCONNECTED,
}

class FlutterPjsip {
  static const MethodChannel _channel = const MethodChannel('flutter_pjsip');

  final StreamController<String> _sipStatusController = StreamController<String>.broadcast();

  Stream<String> get onSipStateChanged => _sipStatusController.stream;

  static final pjsip = FlutterPjsip();

  ///工厂模式
  factory FlutterPjsip() => _getInstance();

  static FlutterPjsip get instance => _getInstance();
  static FlutterPjsip _instance;

  static FlutterPjsip _getInstance() {
    if (_instance == null) {
      _instance = new FlutterPjsip._internal();
    }
    return _instance;
  }

  FlutterPjsip._internal() {
    ///初始化
    _channel.setMethodCallHandler((MethodCall call) async {
      try {
        _doHandlePlatformCall(call);
      } catch (exception) {
        print('Unexpected error: $exception');
      }
    });
  }

  static Future<void> _doHandlePlatformCall(MethodCall call) async {
    final Map<dynamic, dynamic> callArgs = call.arguments as Map;

    final value = callArgs['status'];

    switch (call.method) {
      case 'method_call_status_changed':
        pjsip._sipStatusController.add(value);
        break;

      default:
        print('Unknown method ${call.method} ');
    }
  }

  ///pjsip初始化
  Future<bool> pjsipInit() async {
    return await _channel.invokeMethod('method_pjsip_init');
  }

  ///pjsip登录
  Future<bool> pjsipLogin({String username, String password, String ip, String port}) async {
    Map<String, String> map = {"username": username, "password": password, "ip": ip, "port": port};
    return await _channel.invokeMethod("method_pjsip_login", map);
  }

  ///pjsip拨打电话
  Future<bool> pjsipCall({String username, String ip, String port}) async {
    Map<String, String> map = {"username": username, "ip": ip, "port": port};
    return await _channel.invokeMethod("method_pjsip_call", map);
  }

  ///pjsip登出
  Future<bool> pjsipLogout() async {
    return await _channel.invokeMethod('method_pjsip_logout');
  }

  ///pjsip销毁
  Future<bool> pjsipDeinit() async {
    return await _channel.invokeMethod('method_pjsip_deinit');
  }

  ///pjsip接收电话
  Future<bool> pjsipReceive() async {
    return await _channel.invokeMethod('method_pjsip_receive');
  }

  ///pjsip挂断&&拒接
  Future<bool> pjsipRefuse() async {
    return await _channel.invokeMethod('method_pjsip_refuse');
  }

  ///pjsip免提
  Future<bool> pjsipHandsFree() async {
    return await _channel.invokeMethod('method_pjsip_audio_session');
  }

  ///pjsip静音
  Future<bool> pjsipMute() async {
    return await _channel.invokeMethod('method_pjsip_mute_microphone');
  }

  ///关闭全部StreamController
  Future<void> dispose() async {
    List<Future> futures = [];
    if (!_sipStatusController.isClosed) futures.add(_sipStatusController.close());
    await Future.wait(futures);
  }
}
