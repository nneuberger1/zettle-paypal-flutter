/// Represents a payment amount with currency information
class ZettleAmount {
  final double amount;
  final String currencyCode;

  const ZettleAmount({
    required this.amount,
    required this.currencyCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currencyCode': currencyCode,
    };
  }

  factory ZettleAmount.fromMap(Map<String, dynamic> map) {
    return ZettleAmount(
      amount: (map['amount'] as num).toDouble(),
      currencyCode: map['currencyCode'] as String,
    );
  }

  @override
  String toString() => 'ZettleAmount(amount: $amount, currencyCode: $currencyCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZettleAmount &&
        other.amount == amount &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => amount.hashCode ^ currencyCode.hashCode;
}

/// Represents payment information for a transaction
class ZettlePaymentInfo {
  final ZettleAmount amount;
  final String? reference;
  final bool enableTipping;

  const ZettlePaymentInfo({
    required this.amount,
    this.reference,
    this.enableTipping = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount.toMap(),
      'reference': reference,
      'enableTipping': enableTipping,
    };
  }

  factory ZettlePaymentInfo.fromMap(Map<String, dynamic> map) {
    return ZettlePaymentInfo(
      amount: ZettleAmount.fromMap(map['amount'] as Map<String, dynamic>),
      reference: map['reference'] as String?,
      enableTipping: map['enableTipping'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'ZettlePaymentInfo(amount: $amount, reference: $reference, enableTipping: $enableTipping)';
}

/// Represents card payment information
class ZettleCardPaymentInfo {
  final ZettleAmount amount;
  final String? reference;
  final bool enableTipping;
  final String? receiptId;

  const ZettleCardPaymentInfo({
    required this.amount,
    this.reference,
    this.enableTipping = false,
    this.receiptId,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount.toMap(),
      'reference': reference,
      'enableTipping': enableTipping,
      'receiptId': receiptId,
    };
  }

  factory ZettleCardPaymentInfo.fromMap(Map<String, dynamic> map) {
    return ZettleCardPaymentInfo(
      amount: ZettleAmount.fromMap(map['amount'] as Map<String, dynamic>),
      reference: map['reference'] as String?,
      enableTipping: map['enableTipping'] as bool? ?? false,
      receiptId: map['receiptId'] as String?,
    );
  }

  @override
  String toString() => 'ZettleCardPaymentInfo(amount: $amount, reference: $reference, enableTipping: $enableTipping, receiptId: $receiptId)';
}

/// Represents a completed payment transaction
class ZettlePaymentResult {
  final ZettleAmount amount;
  final ZettleAmount? gratuityAmount;
  final String? reference;
  final String? entryMode;
  final String? authorizationCode;
  final String? obfuscatedPan;
  final String? panHash;
  final String? cardBrand;
  final String? aidName;
  final String? applicationIdentifier;
  final String? receiptId;

  const ZettlePaymentResult({
    required this.amount,
    this.gratuityAmount,
    this.reference,
    this.entryMode,
    this.authorizationCode,
    this.obfuscatedPan,
    this.panHash,
    this.cardBrand,
    this.aidName,
    this.applicationIdentifier,
    this.receiptId,
  });

  factory ZettlePaymentResult.fromMap(Map<String, dynamic> map) {
    return ZettlePaymentResult(
      amount: ZettleAmount.fromMap(map['amount'] as Map<String, dynamic>),
      gratuityAmount: map['gratuityAmount'] != null
          ? ZettleAmount.fromMap(map['gratuityAmount'] as Map<String, dynamic>)
          : null,
      reference: map['reference'] as String?,
      entryMode: map['entryMode'] as String?,
      authorizationCode: map['authorizationCode'] as String?,
      obfuscatedPan: map['obfuscatedPan'] as String?,
      panHash: map['panHash'] as String?,
      cardBrand: map['cardBrand'] as String?,
      aidName: map['aidName'] as String?,
      applicationIdentifier: map['applicationIdentifier'] as String?,
      receiptId: map['receiptId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount.toMap(),
      'gratuityAmount': gratuityAmount?.toMap(),
      'reference': reference,
      'entryMode': entryMode,
      'authorizationCode': authorizationCode,
      'obfuscatedPan': obfuscatedPan,
      'panHash': panHash,
      'cardBrand': cardBrand,
      'aidName': aidName,
      'applicationIdentifier': applicationIdentifier,
      'receiptId': receiptId,
    };
  }

  @override
  String toString() => 'ZettlePaymentResult(amount: $amount, reference: $reference, cardBrand: $cardBrand)';
}

/// Represents a refund transaction
class ZettleRefundInfo {
  final ZettleAmount amount;
  final String? reference;
  final String? receiptId;

  const ZettleRefundInfo({
    required this.amount,
    this.reference,
    this.receiptId,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount.toMap(),
      'reference': reference,
      'receiptId': receiptId,
    };
  }

  factory ZettleRefundInfo.fromMap(Map<String, dynamic> map) {
    return ZettleRefundInfo(
      amount: ZettleAmount.fromMap(map['amount'] as Map<String, dynamic>),
      reference: map['reference'] as String?,
      receiptId: map['receiptId'] as String?,
    );
  }

  @override
  String toString() => 'ZettleRefundInfo(amount: $amount, reference: $reference, receiptId: $receiptId)';
}

/// Represents the result of a refund operation
class ZettleRefundResult {
  final ZettleAmount amount;
  final String? reference;
  final String? receiptId;

  const ZettleRefundResult({
    required this.amount,
    this.reference,
    this.receiptId,
  });

  factory ZettleRefundResult.fromMap(Map<String, dynamic> map) {
    return ZettleRefundResult(
      amount: ZettleAmount.fromMap(map['amount'] as Map<String, dynamic>),
      reference: map['reference'] as String?,
      receiptId: map['receiptId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount.toMap(),
      'reference': reference,
      'receiptId': receiptId,
    };
  }

  @override
  String toString() => 'ZettleRefundResult(amount: $amount, reference: $reference, receiptId: $receiptId)';
}
