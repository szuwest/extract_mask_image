package com.example.extract_mask_image

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.BitmapFactory
import java.io.FileOutputStream
import java.io.File

/** ExtractMaskImagePlugin */
// create by West, szhanfeng203@gmail.com
class ExtractMaskImagePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "extract_mask_image")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "extractMaskImage") {
        // 获取原图和遮罩图的路径
        val originalImagePath = call.argument<String>("originalImagePath")
        val maskImagePath = call.argument<String>("maskImagePath")
        if (originalImagePath == null || maskImagePath == null) {
          result.error("INVALID_ARGUMENT", "Image paths cannot be null", null)
          return
        }
        // 读取原图和遮罩图
        val originalBitmap = BitmapUtils.loadBitmap(originalImagePath)
        val maskBitmap = BitmapUtils.loadBitmap(maskImagePath)
        if (originalBitmap == null || maskBitmap == null) {
          result.error("LOAD_ERROR", "Failed to load images", null)
          return
        }
        if (originalBitmap.width != maskBitmap.width || originalBitmap.height != maskBitmap.height) {
          result.error("SIZE_ERROR", "Image sizes do not match", null)
          return
        }
        // 抠出遮罩图对应的图像
        val resultBitmap = extractMaskedImageByPixel(originalBitmap, maskBitmap)

        // 保存结果图像
        val resultImagePath = BitmapUtils.saveBitmap(resultBitmap)
        if (resultImagePath == null) {
          result.error("SAVE_ERROR", "Failed to save result image", null)
          return
        }
        // 返回结果图像的路径
        result.success(resultImagePath)
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /**
   * 从原图中抠出遮罩图对应的图像
   * @param originalBitmap 原图
   * @param maskBitmap 遮罩图
   * @return 抠出的图像
   */
  fun extractMaskedImageByPixel(originalBitmap: Bitmap, maskBitmap: Bitmap): Bitmap {
    // 创建一个空的Bitmap用于存放结果
    val resultBitmap = Bitmap.createBitmap(
      originalBitmap.width,
      originalBitmap.height,
      Bitmap.Config.ARGB_8888
    )

    // 遍历每一个像素
    for (x in 0 until originalBitmap.width) {
      for (y in 0 until originalBitmap.height) {
        // 获取遮罩图的像素
        val maskPixel = maskBitmap.getPixel(x, y)

//        // 获取遮罩图的透明度
//        val maskAlpha = Color.alpha(maskPixel)
//
//        if (maskAlpha > 0) {
//          // 如果遮罩图的像素不是完全透明，则保留原图的像素
//          val originalPixel = originalBitmap.getPixel(x, y)
//          resultBitmap.setPixel(x, y, originalPixel)
//        } else {
//          // 否则设置为透明
//          resultBitmap.setPixel(x, y, Color.TRANSPARENT)
//        }
//      }

        // 使用亮度公式来计算黑白图像的亮度
        val maskRed = Color.red(maskPixel)
        val maskGreen = Color.green(maskPixel)
        val maskBlue = Color.blue(maskPixel)
        val brightness = 0.299 * maskRed + 0.587 * maskGreen + 0.114 * maskBlue

        if (brightness < 128) {
          // 如果亮度低于128，则设置结果图像的像素为透明
          resultBitmap.setPixel(x, y, Color.TRANSPARENT)
        } else {
          // 否则保留原图的像素
          val originalPixel = originalBitmap.getPixel(x, y)
          resultBitmap.setPixel(x, y, originalPixel)
        }
      }
    }
    return resultBitmap
  }
}

// BitmapUtils.kt
object BitmapUtils {
  // 文件必须为沙盒内部的路径
  fun loadBitmap(path: String?): Bitmap? {
    return try {
      BitmapFactory.decodeFile(path)
    } catch (e: Exception) {
      null
    }
  }

  fun saveBitmap(bitmap: Bitmap): String? {
    return try {
      val file = File.createTempFile("result", ".png")
      val out = FileOutputStream(file)
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
      out.flush()
      out.close()
      file.absolutePath
    } catch (e: Exception) {
      null
    }
  }
}