import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printer_module_bixolon/printer_module_bixolon.dart';

void main() {
  const MethodChannel channel = MethodChannel('printer_module_bixolon');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PrinterModuleBixolon.platformVersion, '42');
  });
}
