import 'package:flutter/services.dart';

class MethodChannelService {
  static const MethodChannel _channel = MethodChannel('web_content_share');

  static Future<void> handleSharedContent(String sharedContent) async {
    try {
      await _channel.invokeMethod('handleSharedContent', sharedContent);
    } on PlatformException catch (e) {
      print("Error invoking method: ${e.message}");
    }
  }
}
