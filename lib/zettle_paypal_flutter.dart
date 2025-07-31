library zettle_paypal_flutter;

import 'zettle_paypal_flutter_platform_interface.dart';
import 'src/models.dart';

// Export public API
export 'src/models.dart';
export 'src/exceptions.dart';

/// Flutter plugin for Zettle (PayPal) iOS SDK integration
///
/// This plugin provides a Dart API wrapper around the native Zettle iOS SDK,
/// enabling payment processing, card reader functionality, and transaction management.
class ZettlePaypalFlutter {
  /// Get the platform version
  Future<String?> getPlatformVersion() {
    return ZettlePaypalFlutterPlatform.instance.getPlatformVersion();
  }

  /// Initialize the Zettle SDK
  ///
  /// This must be called before using any other SDK functions.
  /// It sets up the necessary native SDK components.
  Future<void> initialize() {
    return ZettlePaypalFlutterPlatform.instance.initialize();
  }

  /// Initialize the Zettle SDK explicitly (like AppDelegate)
  ///
  /// This performs the actual SDK initialization similar to what
  /// happens in the sample app's AppDelegate. This creates the
  /// authorization provider and starts the SDK properly.
  Future<void> initializeSDK() {
    return ZettlePaypalFlutterPlatform.instance.initializeSDK();
  }

  /// Check if the SDK is authenticated with Zettle services
  ///
  /// Returns true if the user is logged in and authenticated,
  /// false otherwise.
  Future<bool> isAuthenticated() {
    return ZettlePaypalFlutterPlatform.instance.isAuthenticated();
  }

  /// Authenticate with Zettle using OAuth
  ///
  /// This opens the Zettle login flow where users can enter
  /// their credentials to authenticate with Zettle services.
  ///
  /// Throws [ZettleAuthenticationException] if authentication fails.
  Future<void> authenticate() {
    return ZettlePaypalFlutterPlatform.instance.authenticate();
  }

  /// Logout from Zettle
  ///
  /// This clears the authentication state and logs out the user
  /// from Zettle services.
  Future<void> logout() {
    return ZettlePaypalFlutterPlatform.instance.logout();
  }

  /// Perform a card payment transaction
  ///
  /// [paymentInfo] contains the payment details including amount,
  /// currency, reference, and tipping preferences.
  ///
  /// Returns a [ZettlePaymentResult] with transaction details.
  ///
  /// Throws [ZettleNotAuthenticatedException] if not authenticated.
  /// Throws [ZettlePaymentCancelledException] if user cancels.
  /// Throws [ZettlePaymentFailedException] if payment fails.
  /// Throws [ZettleCardReaderException] if card reader issues occur.
  Future<ZettlePaymentResult> chargeCard(ZettleCardPaymentInfo paymentInfo) {
    return ZettlePaypalFlutterPlatform.instance.chargeCard(paymentInfo);
  }

  /// Perform a refund operation
  ///
  /// [refundInfo] contains the refund details including amount,
  /// currency, and optional reference and receipt ID.
  ///
  /// Returns a [ZettleRefundResult] with refund transaction details.
  ///
  /// Throws [ZettleNotAuthenticatedException] if not authenticated.
  /// Throws [ZettleRefundFailedException] if refund fails.
  Future<ZettleRefundResult> refund(ZettleRefundInfo refundInfo) {
    return ZettlePaypalFlutterPlatform.instance.refund(refundInfo);
  }

  /// Check if a card reader is currently connected
  ///
  /// Returns true if a card reader is connected and ready,
  /// false otherwise.
  Future<bool> isCardReaderConnected() {
    return ZettlePaypalFlutterPlatform.instance.isCardReaderConnected();
  }

  /// Show the card reader settings screen
  ///
  /// This opens the native Zettle card reader settings where
  /// users can pair, configure, and manage card readers.
  Future<void> showCardReaderSettings() {
    return ZettlePaypalFlutterPlatform.instance.showCardReaderSettings();
  }

  /// Get information about the last payment transaction
  ///
  /// Returns [ZettlePaymentResult] of the last payment, or null
  /// if no payment has been made.
  Future<ZettlePaymentResult?> getLastPayment() {
    return ZettlePaypalFlutterPlatform.instance.getLastPayment();
  }

  /// Show the payment settings screen
  ///
  /// This opens the native Zettle payment settings where
  /// users can configure payment preferences and options.
  Future<void> showPaymentSettings() {
    return ZettlePaypalFlutterPlatform.instance.showPaymentSettings();
  }

  /// Show the SDK settings screen
  ///
  /// This opens the native Zettle SDK settings screen by calling
  /// iZettleSDK.shared().presentSettings(from:). This is equivalent
  /// to case 5 in SelectionTableViewController and provides access
  /// to the general SDK settings including account management.
  Future<void> showSettings() {
    return ZettlePaypalFlutterPlatform.instance.showSettings();
  }
}
