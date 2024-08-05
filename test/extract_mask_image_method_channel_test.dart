import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extract_mask_image/extract_mask_image_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelExtractMaskImage platform = MethodChannelExtractMaskImage();
  const MethodChannel channel = MethodChannel('extract_mask_image');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
