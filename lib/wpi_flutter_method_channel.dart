import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wpi_flutter_platform_interface.dart';

/// An implementation of [WpiFlutterPlatform] that uses method channels.
class MethodChannelWpiFlutter extends WpiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wpi_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> processTransaction({required String requestJson, required String serviceType, required String sessionId, required String wpiVersion}) async {
    final response = await methodChannel.invokeMethod('processTransaction', <String, dynamic>{
      'requestJson': requestJson,
      'serviceType': serviceType,
      'sessionId': sessionId,
      'wpiVersion': wpiVersion,
    });

    return response != null ? jsonEncode(response) : null;
  }

  @override
  Future<String?> processOperation({required String requestJson, required String serviceType, bool showOverlay = false}) async {
    final response = await methodChannel.invokeMethod('processOperation', <String, dynamic>{
      'requestJson': requestJson,
      'serviceType': serviceType,
      'showOverlay': showOverlay,
    });

    return response != null ? jsonEncode(response) : null;
  }
}
