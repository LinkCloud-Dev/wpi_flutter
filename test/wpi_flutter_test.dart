import 'package:flutter_test/flutter_test.dart';
import 'package:wpi_flutter/wpi_flutter.dart';
import 'package:wpi_flutter/wpi_flutter_platform_interface.dart';
import 'package:wpi_flutter/wpi_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWpiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements WpiFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WpiFlutterPlatform initialPlatform = WpiFlutterPlatform.instance;

  test('$MethodChannelWpiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWpiFlutter>());
  });

  test('getPlatformVersion', () async {
    WpiFlutter wpiFlutterPlugin = WpiFlutter();
    MockWpiFlutterPlatform fakePlatform = MockWpiFlutterPlatform();
    WpiFlutterPlatform.instance = fakePlatform;

    expect(await wpiFlutterPlugin.getPlatformVersion(), '42');
  });
}
