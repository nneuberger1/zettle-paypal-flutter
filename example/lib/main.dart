import 'package:flutter/material.dart';
import 'dart:async';

import 'package:zettle_paypal_flutter/zettle_paypal_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zettle PayPal Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ZettlePaymentDemo(),
    );
  }
}

class ZettlePaymentDemo extends StatefulWidget {
  const ZettlePaymentDemo({super.key});

  @override
  State<ZettlePaymentDemo> createState() => _ZettlePaymentDemoState();
}

class _ZettlePaymentDemoState extends State<ZettlePaymentDemo> {
  final _zettlePlugin = ZettlePaypalFlutter();

  String _platformVersion = 'Unknown';
  bool _isAuthenticated = false;
  bool _isCardReaderConnected = false;
  bool _isLoading = false;
  ZettlePaymentResult? _lastPayment;

  final _amountController = TextEditingController(text: '1.00');
  final _referenceController = TextEditingController();
  bool _enableTipping = false;

  @override
  void initState() {
    super.initState();
    _initializePlugin();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _initializePlugin() async {
    setState(() => _isLoading = true);

    try {
      // Get platform version
      final platformVersion =
          await _zettlePlugin.getPlatformVersion() ?? 'Unknown';

      // Initialize the SDK
      await _zettlePlugin.initialize();

      // Check authentication status
      final isAuthenticated = await _zettlePlugin.isAuthenticated();

      // Check card reader connection
      final isCardReaderConnected = await _zettlePlugin.isCardReaderConnected();

      // Get last payment if available
      final lastPayment = await _zettlePlugin.getLastPayment();

      if (mounted) {
        setState(() {
          _platformVersion = platformVersion;
          _isAuthenticated = isAuthenticated;
          _isCardReaderConnected = isCardReaderConnected;
          _lastPayment = lastPayment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Initialization Error', e.toString());
      }
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);

    try {
      await _zettlePlugin.authenticate();
      final isAuthenticated = await _zettlePlugin.isAuthenticated();

      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });

        if (isAuthenticated) {
          _showSuccessMessage('Successfully authenticated with Zettle');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Authentication Error', e.toString());
      }
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      await _zettlePlugin.logout();

      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
        _showSuccessMessage('Successfully logged out');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Logout Error', e.toString());
      }
    }
  }

  Future<void> _processPayment() async {
    if (!_isAuthenticated) {
      _showErrorDialog('Not Authenticated', 'Please authenticate first');
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showErrorDialog('Invalid Amount', 'Please enter a valid amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorDialog(
        'Invalid Amount',
        'Please enter a valid positive amount',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentInfo = ZettleCardPaymentInfo(
        amount: ZettleAmount(amount: amount, currencyCode: 'USD'),
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        enableTipping: _enableTipping,
      );

      final result = await _zettlePlugin.chargeCard(paymentInfo);

      if (mounted) {
        setState(() {
          _lastPayment = result;
          _isLoading = false;
        });

        _showPaymentResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e is ZettlePaymentCancelledException) {
          _showSuccessMessage('Payment was cancelled');
        } else {
          _showErrorDialog('Payment Error', e.toString());
        }
      }
    }
  }

  Future<void> _processRefund() async {
    if (!_isAuthenticated) {
      _showErrorDialog('Not Authenticated', 'Please authenticate first');
      return;
    }

    if (_lastPayment == null) {
      _showErrorDialog('No Payment', 'No recent payment to refund');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final refundInfo = ZettleRefundInfo(
        amount: _lastPayment!.amount,
        reference: _lastPayment!.reference,
        receiptId: _lastPayment!.receiptId,
      );

      final result = await _zettlePlugin.refund(refundInfo);

      if (mounted) {
        setState(() => _isLoading = false);
        _showRefundResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Refund Error', e.toString());
      }
    }
  }

  Future<void> _showCardReaderSettings() async {
    try {
      await _zettlePlugin.showCardReaderSettings();
    } catch (e) {
      _showErrorDialog('Settings Error', e.toString());
    }
  }

  Future<void> _showPaymentSettings() async {
    try {
      await _zettlePlugin.showPaymentSettings();
    } catch (e) {
      _showErrorDialog('Settings Error', e.toString());
    }
  }

  Future<void> _showSettings() async {
    try {
      await _zettlePlugin.showSettings();
    } catch (e) {
      _showErrorDialog('Settings Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showPaymentResultDialog(ZettlePaymentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${result.amount.amount} ${result.amount.currencyCode}',
            ),
            if (result.gratuityAmount != null)
              Text(
                'Tip: ${result.gratuityAmount!.amount} ${result.gratuityAmount!.currencyCode}',
              ),
            if (result.reference != null)
              Text('Reference: ${result.reference}'),
            if (result.cardBrand != null) Text('Card: ${result.cardBrand}'),
            if (result.obfuscatedPan != null)
              Text('PAN: ${result.obfuscatedPan}'),
            if (result.authorizationCode != null)
              Text('Auth Code: ${result.authorizationCode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRefundResultDialog(ZettleRefundResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${result.amount.amount} ${result.amount.currencyCode}',
            ),
            if (result.reference != null)
              Text('Reference: ${result.reference}'),
            if (result.receiptId != null)
              Text('Receipt ID: ${result.receiptId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zettle PayPal Flutter Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Platform: $_platformVersion'),
                          Text(
                            'Authenticated: ${_isAuthenticated ? 'Yes' : 'No'}',
                          ),
                          Text(
                            'Card Reader Connected: ${_isCardReaderConnected ? 'Yes' : 'No'}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Authentication Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authentication',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isAuthenticated
                                      ? null
                                      : _authenticate,
                                  child: const Text('Login'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isAuthenticated ? _logout : null,
                                  child: const Text('Logout'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount (USD)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _referenceController,
                            decoration: const InputDecoration(
                              labelText: 'Reference (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('Enable Tipping'),
                            value: _enableTipping,
                            onChanged: (value) {
                              setState(() {
                                _enableTipping = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAuthenticated
                                  ? _processPayment
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Process Payment'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isAuthenticated && _lastPayment != null
                                  ? _processRefund
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Refund Last Payment'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _showCardReaderSettings,
                                  child: const Text('Card Reader Settings'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _showPaymentSettings,
                                  child: const Text('Payment Settings'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('SDK Settings (Account Flow)'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Last Payment Section
                  if (_lastPayment != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Payment',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Amount: ${_lastPayment!.amount.amount} ${_lastPayment!.amount.currencyCode}',
                            ),
                            if (_lastPayment!.reference != null)
                              Text('Reference: ${_lastPayment!.reference}'),
                            if (_lastPayment!.cardBrand != null)
                              Text('Card: ${_lastPayment!.cardBrand}'),
                            if (_lastPayment!.obfuscatedPan != null)
                              Text('PAN: ${_lastPayment!.obfuscatedPan}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
