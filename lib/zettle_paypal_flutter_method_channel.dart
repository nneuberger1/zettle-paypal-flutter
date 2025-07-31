import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zettle_paypal_flutter_platform_interface.dart';
import 'src/models.dart';
import 'src/exceptions.dart';

/// An implementation of [ZettlePaypalFlutterPlatform] that uses method channels.
class MethodChannelZettlePaypalFlutter extends ZettlePaypalFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zettle_paypal_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initialize() async {
    try {
      await methodChannel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isAuthenticated');
      return result ?? false;
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<void> authenticate() async {
    try {
      await methodChannel.invokeMethod('authenticate');
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await methodChannel.invokeMethod('logout');
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<ZettlePaymentResult> chargeCard(ZettleCardPaymentInfo paymentInfo) async {
    try {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
        'chargeCard',
        paymentInfo.toMap(),
      );
      if (result == null) {
        throw const ZettlePaymentFailedException('No payment result received');
      }
      return ZettlePaymentResult.fromMap(result);
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<ZettleRefundResult> refund(ZettleRefundInfo refundInfo) async {
    try {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
        'refund',
        refundInfo.toMap(),
      );
      if (result == null) {
        throw const ZettleRefundFailedException('No refund result received');
      }
      return ZettleRefundResult.fromMap(result);
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<bool> isCardReaderConnected() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isCardReaderConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<void> showCardReaderSettings() async {
    try {
      await methodChannel.invokeMethod('showCardReaderSettings');
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<ZettlePaymentResult?> getLastPayment() async {
    try {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>('getLastPayment');
      if (result == null) return null;
      return ZettlePaymentResult.fromMap(result);
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }

  @override
  Future<void> showPaymentSettings() async {
    try {
      await methodChannel.invokeMethod('showPaymentSettings');
    } on PlatformException catch (e) {
      throw ZettleExceptionFactory.fromPlatformException(e.code, e.message);
    }
  }
}
