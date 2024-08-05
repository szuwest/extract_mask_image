import Flutter
import UIKit

// create by West, szhanfeng203@gmail.com
public class ExtractMaskImagePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "extract_mask_image", binaryMessenger: registrar.messenger())
    let instance = ExtractMaskImagePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "extractMaskImage":
        guard let arguments = call.arguments as? [String: Any],
                let originalImagePath = arguments["originalImagePath"] as? String,
                let maskImagePath = arguments["maskImagePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let originalImage = UIImage(contentsOfFile: originalImagePath),
                let maskImage = UIImage(contentsOfFile: maskImagePath) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Invalid image", details: nil))
            return
        }

        guard let maskedImage = extractMaskedImage(originalImage: originalImage, maskImage: maskImage) else {
            result(FlutterError(code: "EXTRACT_FAILED", message: "Extract failed", details: nil))
            return
        }

        let time = Int(Date().timeIntervalSince1970)
        let maskedImagePath = NSTemporaryDirectory() + "\(time)_maskedImage.png"
        let maskedImageData = maskedImage.pngData()
        do {
            try maskedImageData?.write(to: URL(fileURLWithPath: maskedImagePath))
            result(maskedImagePath)
        } catch {
            result(FlutterError(code: "WRITE_FAILED", message: "Write failed", details: nil))
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /**
   从原图中抠出遮罩图对应的图像
   - Parameters:
     - originalImage: 原图
     - maskImage: 遮罩图
   - Returns: 抠出的图像
   */
  func extractMaskedImage(originalImage: UIImage, maskImage: UIImage) -> UIImage? {
      guard let originalCGImage = originalImage.cgImage,
            let maskCGImage = maskImage.cgImage else {
          return nil
      }

      let width = originalCGImage.width
      let height = originalCGImage.height

      guard width == maskCGImage.width, height == maskCGImage.height else {
          return nil
      }

      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

      guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else {
          return nil
      }

      context.draw(originalCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
      guard let originalData = context.data else {
          return nil
      }

      guard let maskContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: bitmapInfo) else {
          return nil
      }
      maskContext.draw(maskCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
       guard let maskData = maskContext.data else {
           return nil
       }

      let originalPixels = originalData.bindMemory(to: UInt8.self, capacity: width * height * 4)
      let maskPixels = maskData.bindMemory(to: UInt8.self, capacity: width * height * 4)

     for x in 0..<width {
         for y in 0..<height {
             let pixelIndex = (y * width + x) * 4

//              let maskAlpha = maskPixels[pixelIndex + 3]
//              if maskAlpha == 0 {
//                  originalPixels[pixelIndex] = 0
//                  originalPixels[pixelIndex + 1] = 0
//                  originalPixels[pixelIndex + 2] = 0
//                  originalPixels[pixelIndex + 3] = 0
//              }
             let maskRed = maskPixels[pixelIndex]
             let maskGreen = maskPixels[pixelIndex + 1]
             let maskBlue = maskPixels[pixelIndex + 2]
             
             // 使用亮度公式来计算黑白图像的亮度
             let brightness = 0.299 * Double(maskRed) + 0.587 * Double(maskGreen) + 0.114 * Double(maskBlue)
             
             if brightness < 128 {
                 originalPixels[pixelIndex] = 0
                 originalPixels[pixelIndex + 1] = 0
                 originalPixels[pixelIndex + 2] = 0
                 originalPixels[pixelIndex + 3] = 0
             }
         }
     }

      guard let outputCGImage = context.makeImage() else {
          return nil
      }

      return UIImage(cgImage: outputCGImage)
  }

}
