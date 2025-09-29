import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wpi_flutter/wpi_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _wpiFlutterPlugin = WpiFlutter();
  
  // Store last transaction session ID for reversal and refund operations
  String? _lastTransactionSessionId;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _wpiFlutterPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // ==================== Request Builders ====================
  
  String _buildPurchaseRequest() {
    final request = {
      'currency': 'AUD',                    // Currency code (ISO 4217)
      'requestedAmount': 1022,              // 10.22AUD = 1022 cents (minor currency unit)
      'reference': 'TXN-${DateTime.now().millisecondsSinceEpoch}', // Transaction reference
      'receiptFormat': 'FORMATTED',         // Receipt format
    };
    return jsonEncode(request);
  }

  String _buildReversalRequest() {
    final request = {
      // TODO: Implement reversal request fields
    };
    return jsonEncode(request);
  }

  String _buildRefundRequest() {
    final request = {
      // TODO: Implement refund request fields
    };
    return jsonEncode(request);
  }


  // ==================== WPI API Calls ====================
  
  Future<void> purchase() async {
    try {
      final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _wpiFlutterPlugin.processPayment(
        requestJson: _buildPurchaseRequest(),
        sessionId: sessionId,
      );
      
      _lastTransactionSessionId = sessionId;
      print('Purchase Response: $response');
    } catch (e) {
      print('Purchase failed: $e');
    }
  }

  Future<void> reversal() async {
    try {
      final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _wpiFlutterPlugin.cancelPayment(
        requestJson: _buildReversalRequest(),
        sessionId: sessionId,
      );
      
      // Store this session ID for future operations
      _lastTransactionSessionId = sessionId;
      print('Reversal Response: $response');
    } catch (e) {
      print('Reversal failed: $e');
    }
  }

  Future<void> refund() async {
    try {
      final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _wpiFlutterPlugin.processRefund(
        requestJson: _buildRefundRequest(),
        sessionId: sessionId,
      );
      
      // Store this session ID for future operations
      _lastTransactionSessionId = sessionId;
      print('Refund Response: $response');
    } catch (e) {
      print('Refund failed: $e');
    }
  }

  // Check last transaction status
  Future<void> checkLastTransaction() async {
    if (_lastTransactionSessionId == null) {
      print('Check Last Transaction failed: No previous transaction found.');
      return;
    }
    
    try {
      final response = await _wpiFlutterPlugin.checkLastTransaction(
        sessionId: _lastTransactionSessionId!,
      );
      print('Last Transaction Status: $response');
    } catch (e) {
      print('Check Last Transaction failed: $e');
    }
  }

  // Check application status
  Future<void> checkApplicationStatus() async {
    try {
      final response = await _wpiFlutterPlugin.checkApplicationStatus();
      print('Application Status: $response');
    } catch (e) {
      print('Check Application Status failed: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WPI Flutter Plugin Test'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // WPI Test Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WPI Test',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: purchase,
                              child: const Text('Payment'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: reversal,
                              child: const Text('Reversal'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: refund,
                              child: const Text('Refund'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: checkLastTransaction,
                              child: const Text('Check Last TX'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // WMI Test Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WMI Test',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: checkApplicationStatus,
                              child: const Text('Check App Status'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

