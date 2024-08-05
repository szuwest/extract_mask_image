import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:extract_mask_image/extract_mask_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _extractMaskImagePlugin = ExtractMaskImage();
  String? _extractedImagePath;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _extractMaskImagePlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Extract Mask Image'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // const SizedBox(height: 10),
              Text('Running on: $_platformVersion\n'),
              const SizedBox(height: 10),
              const Text('Original image:'),
              Image.asset("images/origin.png"),
              const SizedBox(height: 10),
              const Text('mask image:'),
              Image.asset("images/mask.jpeg"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  _onTapButton(context);
                },
                child: const Text('Extract mask image'),
              ),
              if (_isExtracting)
                const CircularProgressIndicator(),
              if (_extractedImagePath != null)
                ...[const Text("Result:"), Image.file(File(_extractedImagePath!))],
              const SizedBox(height: 20),
            ],
          ),
        )
      ),
    );
  }

  _onTapButton(BuildContext context) async {
    if (_isExtracting) {
      return;
    }
    setState(() {
      _isExtracting = true;
    });
    final originalImagePath = await copyAssetToTempDirectory('images/origin.png');
    final maskImagePath = await copyAssetToTempDirectory('images/mask.jpeg');
    try {
      final result = await _extractMaskImagePlugin.extractMaskImage(
          originalImagePath.path, maskImagePath.path);
      debugPrint('Extracted image path: $result');
      if (result != null) {
        setState(() {
          _extractedImagePath = result;
        });
      } else {
        debugPrint('Extracted image path: $result');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to extract mask image'),
        ));
      }
    } catch (e) {
      debugPrint('Failed to extract mask image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to extract mask image: $e'),
      ));
    }
    setState(() {
      _isExtracting = false;
    });
  }
}

Future<File> copyAssetToTempDirectory(String assetPath) async {
  // 获取临时目录
  final tempDir = await getTemporaryDirectory();
  final fileName = path.basename(assetPath);
  final tempFilePath = path.join(tempDir.path, fileName);

  // 读取资产中的图片
  final byteData = await rootBundle.load(assetPath);

  // 将图片写入临时文件
  final buffer = byteData.buffer;
  return File(tempFilePath).writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
}