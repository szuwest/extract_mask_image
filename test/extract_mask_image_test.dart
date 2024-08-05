import 'package:flutter_test/flutter_test.dart';
import 'package:extract_mask_image/extract_mask_image.dart';
import 'package:extract_mask_image/extract_mask_image_platform_interface.dart';
import 'package:extract_mask_image/extract_mask_image_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExtractMaskImagePlatform
    with MockPlatformInterfaceMixin
    implements ExtractMaskImagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> extractMaskImage(String originalImagePath, String maskImagePath) {
    throw UnimplementedError('extractMaskImage() has not been implemented.');
  }
}

void main() {
  final ExtractMaskImagePlatform initialPlatform = ExtractMaskImagePlatform.instance;

  test('$MethodChannelExtractMaskImage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelExtractMaskImage>());
  });

  test('getPlatformVersion', () async {
    ExtractMaskImage extractMaskImagePlugin = ExtractMaskImage();
    MockExtractMaskImagePlatform fakePlatform = MockExtractMaskImagePlatform();
    ExtractMaskImagePlatform.instance = fakePlatform;

    expect(await extractMaskImagePlugin.getPlatformVersion(), '42');
  });
}
