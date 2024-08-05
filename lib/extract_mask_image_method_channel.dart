import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'extract_mask_image_platform_interface.dart';

/// An implementation of [ExtractMaskImagePlatform] that uses method channels.
class MethodChannelExtractMaskImage extends ExtractMaskImagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('extract_mask_image');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> extractMaskImage(String originalImagePath, String maskImagePath) async {
    final result = await methodChannel.invokeMethod<String>('extractMaskImage', <String, String>{
      'originalImagePath': originalImagePath,
      'maskImagePath': maskImagePath,
    });
    return result;
  }
}
