
import 'extract_mask_image_platform_interface.dart';

class ExtractMaskImage {
  Future<String?> getPlatformVersion() {
    return ExtractMaskImagePlatform.instance.getPlatformVersion();
  }

  Future<String?> extractMaskImage(String originalImagePath, String maskImagePath) {
    return ExtractMaskImagePlatform.instance.extractMaskImage(originalImagePath, maskImagePath);
  }
}
