import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wpi_flutter_method_channel.dart';

abstract class WpiFlutterPlatform extends PlatformInterface {
  /// Constructs a WpiFlutterPlatform.
  WpiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static WpiFlutterPlatform _instance = MethodChannelWpiFlutter();

  /// The default instance of [WpiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelWpiFlutter].
  static WpiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WpiFlutterPlatform] when
  /// they register themselves.
  static set instance(WpiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> processTransaction({
    required String requestJson,
    required String serviceType,
    required String sessionId,
    required String wpiVersion,
  }) {
    throw UnimplementedError('processTransaction() has not been implemented.');
  }

  Future<String?> processOperation({
    required String requestJson,
    required String serviceType,
    required bool showOverlay,
  }) {
    throw UnimplementedError('processOperation() has not been implemented.');
  }
}
