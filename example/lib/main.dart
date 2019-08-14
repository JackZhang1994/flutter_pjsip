import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pjsip/flutter_pjsip.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initSuccess = false;
  bool _loginSuccess = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Sip初始化'),
              onPressed: () => {_sipInit()},
            ),
            Text('PjSip Init : $_initSuccess\n'),
            RaisedButton(
              child: Text('Sip登录'),
              onPressed: () => {_sipLogin()},
            ),
            Text('PjSip Login : $_loginSuccess\n'),
            RaisedButton(
              child: Text('Sip打电话'),
              onPressed: () => {_sipCall()},
            ),
            RaisedButton(
              child: Text('Sip登出'),
              onPressed: () => {_sipLogout()},
            ),
            RaisedButton(
              child: Text('Sip销毁'),
              onPressed: () => {_sipDeinit()},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sipInit() async {
    await FlutterPjsip.pjsipInit();
  }

  Future<void> _sipLogin() async {
    bool loginSuccess =
        await FlutterPjsip.pjsipLogin(username: '1012', password: '123@jvtd', ip: '117.78.34.48', port: '6050');

    setState(() {
      _loginSuccess = loginSuccess;
    });
  }

  Future<void> _sipCall() async {
    await FlutterPjsip.pjsipCall(username: '1010', ip: '117.78.34.48', port: '6050');
  }

  Future<void> _sipLogout() async {
    bool logoutSuccess = await FlutterPjsip.pjsipLogout();
    setState(() {
      _loginSuccess = !logoutSuccess;
    });
  }

  Future<void> _sipDeinit() async {
    await FlutterPjsip.pjsipDeinit();
  }
}
