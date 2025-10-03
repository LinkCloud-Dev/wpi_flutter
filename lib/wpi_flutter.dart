
library wpi_flutter;

export 'wpi_model.dart';

import 'dart:convert';

import 'package:wpi_flutter/wpi_model.dart';

import 'wpi_flutter_platform_interface.dart';

/// WPI Flutter Plugin
/// 
/// A Flutter plugin for integrating with Worldline Payment Interface (WPI).
/// Provides methods for payment processing, transaction reversal, refunds, and transaction status checking.
class WpiFlutter {
  Future<String?> getPlatformVersion() {
    return WpiFlutterPlatform.instance.getPlatformVersion();
  }

  /// Process a WMI operation
  ///
  /// Direct method to call WMI operations with custom service type.
  /// This is a generic method for all WMI operations.
  ///
  /// [requestJson] - JSON string containing operation request data
  /// [serviceType] - WMI service type (e.g., WPI_SVC_CANCEL_PAYMENT, WPI_SVC_REFUND, etc.)
  /// [showOverlay] - Whether to show overlay during processing (default: true)
  ///
  /// Returns the WMI response as JSON string, or null if failed
  Future<Map<String, dynamic>?> _processOperation({
    required String requestJson,
    required String serviceType,
    bool showOverlay = true,
  }) {
    return WpiFlutterPlatform.instance.processOperation(
      requestJson: requestJson,
      serviceType: serviceType,
      showOverlay: showOverlay,
    );
  }

  /// Internal method for processing all transaction types
  /// 
  /// [requestJson] - JSON string containing transaction data
  /// [serviceType] - WPI service type (WPI_SVC_PAYMENT, WPI_SVC_CANCEL_PAYMENT, etc.)
  /// [sessionId] - Unique session identifier for the transaction
  /// [wpiVersion] - WPI version to use (default: v2.2)
  Future<Map<String, dynamic>?> _processTransaction({
    required String requestJson,
    required String serviceType,
    required String sessionId,
    String wpiVersion = "v2.2",
  }) {
    return WpiFlutterPlatform.instance.processTransaction(
      requestJson: requestJson,
      serviceType: serviceType,
      sessionId: sessionId,
      wpiVersion: wpiVersion,
    );
  }

  /// Process a payment transaction
  /// 
  /// Initiates a purchase transaction using WPI_SVC_PAYMENT service type.
  /// 
  /// [requestJson] - JSON string containing payment request data
  /// [sessionId] - Unique session identifier for the transaction
  /// 
  /// Returns the WPI response as JSON string, or null if failed
  Future<WpiResponse?> processPayment({
    required String requestJson,
    required String sessionId,
  }) async {
    final map = await _processTransaction(
        requestJson: requestJson,
        serviceType: "WPI_SVC_PAYMENT",
        sessionId: sessionId);
    return WpiResponse.fromChannelMap(map);
  }

  /// Cancel or reverse a transaction
  /// 
  /// Initiates a transaction reversal using WPI_SVC_CANCEL_PAYMENT service type.
  /// Used to reverse transactions on the same day.
  /// 
  /// [requestJson] - JSON string containing reversal request data
  /// [sessionId] - Unique session identifier for the transaction
  /// 
  /// Returns the WPI response as JSON string, or null if failed
  Future<WpiResponse?> cancelPayment({
    required String requestJson,
    required String sessionId,
  }) async {
    final map = await _processTransaction(
        requestJson: requestJson,
        serviceType: "WPI_SVC_CANCEL_PAYMENT",
        sessionId: sessionId);
    return WpiResponse.fromChannelMap(map);
  }

  /// Process a refund transaction
  /// 
  /// Initiates a refund transaction using WPI_SVC_REFUND service type.
  /// Used for cross-day refunds, requires original transaction information.
  /// 
  /// [requestJson] - JSON string containing refund request data
  /// [sessionId] - Unique session identifier for the transaction
  /// 
  /// Returns the WPI response as JSON string, or null if failed
  Future<WpiResponse?> processRefund({
    required String requestJson,
    required String sessionId,
  }) async {
    final map = await _processTransaction(
        requestJson: requestJson,
        serviceType: "WPI_SVC_REFUND",
        sessionId: sessionId);
    return WpiResponse.fromChannelMap(map);
  }

  /// Check the status of the last transaction
  /// 
  /// Queries the status of the last transaction using WPI_SVC_LAST_TRANSACTION service type.
  /// This is useful for transaction recovery and status checking.
  ///
  /// [sessionId] - Session ID of the transaction to check
  ///
  /// Returns the WPI response containing the last transaction status, or null if failed
  Future<WpiResponse?> checkLastTransaction({
    required String sessionId,
  }) async {
    final map = await _processTransaction(
        requestJson: "{}",
        serviceType: "WPI_SVC_LAST_TRANSACTION",
        sessionId: sessionId);
    return WpiResponse.fromChannelMap(map);
  }

  /// Check application status
  /// 
  /// Checks the current Tap on Mobile application status to determine if it is
  /// properly authenticated and ready to perform payment acceptance functions.
  /// This function is intended to be used outside of payment acceptance context.
  ///
  ///
  /// Returns the WMI response containing the application status, or null if failed
  Future<WmiResponse?> checkApplicationStatus() async {
    final map = await _processOperation(
        requestJson: "{}",
        serviceType: "WMI_SVC_CHECK_STATUS"
    );
    return WmiResponse.fromChannelMap(map);
  }

  Future<WmiResponse?> registerTerminal({
    required String? registrationToken,
  }) async {
    final req = registrationToken == null ? {} : {"registrationToken": registrationToken};
    final map = await _processOperation(
        requestJson: jsonEncode(req),
        serviceType: "WMI_SVC_REGISTER"
    );
    return WmiResponse.fromChannelMap(map);
  }

  Future<WmiResponse?> unregisterTerminal() async {
    final map = await _processOperation(
        requestJson: "{}",
        serviceType: "WMI_SVC_AUTH_UNREGISTER"
    );
    return WmiResponse.fromChannelMap(map);
  }
}
