/// Base exception class for Zettle operations
abstract class ZettleException implements Exception {
  final String message;
  final String? code;

  const ZettleException(this.message, {this.code});

  @override
  String toString() => 'ZettleException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when the SDK is not authenticated
class ZettleNotAuthenticatedException extends ZettleException {
  const ZettleNotAuthenticatedException([String? message])
      : super(message ?? 'Zettle SDK is not authenticated. Please login first.');
}

/// Thrown when a payment operation is cancelled by the user
class ZettlePaymentCancelledException extends ZettleException {
  const ZettlePaymentCancelledException([String? message])
      : super(message ?? 'Payment was cancelled by the user.');
}

/// Thrown when a payment operation fails
class ZettlePaymentFailedException extends ZettleException {
  const ZettlePaymentFailedException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when a refund operation fails
class ZettleRefundFailedException extends ZettleException {
  const ZettleRefundFailedException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when there are issues with card reader connectivity
class ZettleCardReaderException extends ZettleException {
  const ZettleCardReaderException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when authentication fails
class ZettleAuthenticationException extends ZettleException {
  const ZettleAuthenticationException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when an operation is attempted with invalid parameters
class ZettleInvalidParameterException extends ZettleException {
  const ZettleInvalidParameterException(String message, {String? code})
      : super(message, code: code);
}

/// Thrown when a network operation fails
class ZettleNetworkException extends ZettleException {
  const ZettleNetworkException(String message, {String? code})
      : super(message, code: code);
}

/// Factory for creating appropriate exceptions from platform errors
class ZettleExceptionFactory {
  static ZettleException fromPlatformException(String code, String? message) {
    switch (code) {
      case 'NOT_AUTHENTICATED':
        return ZettleNotAuthenticatedException(message);
      case 'PAYMENT_CANCELLED':
        return ZettlePaymentCancelledException(message);
      case 'PAYMENT_FAILED':
        return ZettlePaymentFailedException(message ?? 'Payment failed', code: code);
      case 'REFUND_FAILED':
        return ZettleRefundFailedException(message ?? 'Refund failed', code: code);
      case 'CARD_READER_ERROR':
        return ZettleCardReaderException(message ?? 'Card reader error', code: code);
      case 'AUTHENTICATION_FAILED':
        return ZettleAuthenticationException(message ?? 'Authentication failed', code: code);
      case 'INVALID_PARAMETER':
        return ZettleInvalidParameterException(message ?? 'Invalid parameter', code: code);
      case 'NETWORK_ERROR':
        return ZettleNetworkException(message ?? 'Network error', code: code);
      default:
        return ZettlePaymentFailedException(message ?? 'Unknown error occurred', code: code);
    }
  }
}
