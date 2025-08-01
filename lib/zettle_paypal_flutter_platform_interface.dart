import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zettle_paypal_flutter_method_channel.dart';
import 'src/models.dart';

abstract class ZettlePaypalFlutterPlatform extends PlatformInterface {
  /// Constructs a ZettlePaypalFlutterPlatform.
  ZettlePaypalFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZettlePaypalFlutterPlatform _instance =
      MethodChannelZettlePaypalFlutter();

  /// The default instance of [ZettlePaypalFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelZettlePaypalFlutter].
  static ZettlePaypalFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZettlePaypalFlutterPlatform] when
  /// they register themselves.
  static set instance(ZettlePaypalFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get platform version
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize the Zettle SDK
  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Initialize the Zettle SDK explicitly (like AppDelegate)
  Future<void> initializeSDK({
    required String clientId,
    required String callbackURL,
  }) {
    throw UnimplementedError('initializeSDK() has not been implemented.');
  }

  /// Check if the SDK is authenticated
  Future<bool> isAuthenticated() {
    throw UnimplementedError('isAuthenticated() has not been implemented.');
  }

  /// Authenticate with Zettle using OAuth
  Future<void> authenticate() {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  /// Logout from Zettle
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  /// Perform a card payment
  Future<ZettlePaymentResult> chargeCard(ZettleCardPaymentInfo paymentInfo) {
    throw UnimplementedError('chargeCard() has not been implemented.');
  }

  /// Perform a refund
  Future<ZettleRefundResult> refund(ZettleRefundInfo refundInfo) {
    throw UnimplementedError('refund() has not been implemented.');
  }

  /// Check if card reader is connected
  Future<bool> isCardReaderConnected() {
    throw UnimplementedError(
      'isCardReaderConnected() has not been implemented.',
    );
  }

  /// Show card reader settings
  Future<void> showCardReaderSettings() {
    throw UnimplementedError(
      'showCardReaderSettings() has not been implemented.',
    );
  }

  /// Get last payment information
  Future<ZettlePaymentResult?> getLastPayment() {
    throw UnimplementedError('getLastPayment() has not been implemented.');
  }

  /// Show payment settings
  Future<void> showPaymentSettings() {
    throw UnimplementedError('showPaymentSettings() has not been implemented.');
  }

  /// Show SDK settings (equivalent to presentSettings in iOS SDK)
  Future<void> showSettings() {
    throw UnimplementedError('showSettings() has not been implemented.');
  }
}
