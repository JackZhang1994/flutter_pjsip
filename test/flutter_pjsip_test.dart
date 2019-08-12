import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pjsip/flutter_pjsip.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_pjsip');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterPjsip.platformVersion, '42');
  });
}
