import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'extract_mask_image_method_channel.dart';

abstract class ExtractMaskImagePlatform extends PlatformInterface {
  /// Constructs a ExtractMaskImagePlatform.
  ExtractMaskImagePlatform() : super(token: _token);

  static final Object _token = Object();

  static ExtractMaskImagePlatform _instance = MethodChannelExtractMaskImage();

  /// The default instance of [ExtractMaskImagePlatform] to use.
  ///
  /// Defaults to [MethodChannelExtractMaskImage].
  static ExtractMaskImagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExtractMaskImagePlatform] when
  /// they register themselves.
  static set instance(ExtractMaskImagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> extractMaskImage(String originalImagePath, String maskImagePath) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
