import 'package:flutter_test/flutter_test.dart';
import 'package:zettle_paypal_flutter/zettle_paypal_flutter.dart';
import 'package:zettle_paypal_flutter/zettle_paypal_flutter_platform_interface.dart';
import 'package:zettle_paypal_flutter/zettle_paypal_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockZettlePaypalFlutterPlatform
    with MockPlatformInterfaceMixin
    implements ZettlePaypalFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> initialize() => Future.value();

  @override
  Future<bool> isAuthenticated() => Future.value(false);

  @override
  Future<void> authenticate() => Future.value();

  @override
  Future<void> logout() => Future.value();

  @override
  Future<ZettlePaymentResult> chargeCard(ZettleCardPaymentInfo paymentInfo) =>
      Future.value(ZettlePaymentResult(
        amount: paymentInfo.amount,
        reference: paymentInfo.reference,
      ));

  @override
  Future<ZettleRefundResult> refund(ZettleRefundInfo refundInfo) =>
      Future.value(ZettleRefundResult(
        amount: refundInfo.amount,
        reference: refundInfo.reference,
      ));

  @override
  Future<bool> isCardReaderConnected() => Future.value(true);

  @override
  Future<void> showCardReaderSettings() => Future.value();

  @override
  Future<ZettlePaymentResult?> getLastPayment() => Future.value(null);

  @override
  Future<void> showPaymentSettings() => Future.value();
}

void main() {
  final ZettlePaypalFlutterPlatform initialPlatform = ZettlePaypalFlutterPlatform.instance;

  test('$MethodChannelZettlePaypalFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZettlePaypalFlutter>());
  });

  test('getPlatformVersion', () async {
    ZettlePaypalFlutter zettlePaypalFlutterPlugin = ZettlePaypalFlutter();
    MockZettlePaypalFlutterPlatform fakePlatform = MockZettlePaypalFlutterPlatform();
    ZettlePaypalFlutterPlatform.instance = fakePlatform;

    expect(await zettlePaypalFlutterPlugin.getPlatformVersion(), '42');
  });

  test('initialize', () async {
    ZettlePaypalFlutter zettlePaypalFlutterPlugin = ZettlePaypalFlutter();
    MockZettlePaypalFlutterPlatform fakePlatform = MockZettlePaypalFlutterPlatform();
    ZettlePaypalFlutterPlatform.instance = fakePlatform;

    expect(() => zettlePaypalFlutterPlugin.initialize(), returnsNormally);
  });

  test('chargeCard', () async {
    ZettlePaypalFlutter zettlePaypalFlutterPlugin = ZettlePaypalFlutter();
    MockZettlePaypalFlutterPlatform fakePlatform = MockZettlePaypalFlutterPlatform();
    ZettlePaypalFlutterPlatform.instance = fakePlatform;

    final paymentInfo = ZettleCardPaymentInfo(
      amount: ZettleAmount(amount: 10.0, currencyCode: 'USD'),
      reference: 'TEST_REF',
    );

    final result = await zettlePaypalFlutterPlugin.chargeCard(paymentInfo);
    expect(result.amount.amount, 10.0);
    expect(result.amount.currencyCode, 'USD');
    expect(result.reference, 'TEST_REF');
  });

  test('refund', () async {
    ZettlePaypalFlutter zettlePaypalFlutterPlugin = ZettlePaypalFlutter();
    MockZettlePaypalFlutterPlatform fakePlatform = MockZettlePaypalFlutterPlatform();
    ZettlePaypalFlutterPlatform.instance = fakePlatform;

    final refundInfo = ZettleRefundInfo(
      amount: ZettleAmount(amount: 5.0, currencyCode: 'USD'),
      reference: 'REFUND_REF',
    );

    final result = await zettlePaypalFlutterPlugin.refund(refundInfo);
    expect(result.amount.amount, 5.0);
    expect(result.amount.currencyCode, 'USD');
    expect(result.reference, 'REFUND_REF');
  });

  test('isCardReaderConnected', () async {
    ZettlePaypalFlutter zettlePaypalFlutterPlugin = ZettlePaypalFlutter();
    MockZettlePaypalFlutterPlatform fakePlatform = MockZettlePaypalFlutterPlatform();
    ZettlePaypalFlutterPlatform.instance = fakePlatform;

    expect(await zettlePaypalFlutterPlugin.isCardReaderConnected(), true);
  });
}
