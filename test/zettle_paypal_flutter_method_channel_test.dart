import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zettle_paypal_flutter/zettle_paypal_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelZettlePaypalFlutter platform = MethodChannelZettlePaypalFlutter();
  const MethodChannel channel = MethodChannel('zettle_paypal_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
