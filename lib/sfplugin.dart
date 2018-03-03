import 'dart:async';

import 'package:flutter/services.dart';

class Sfplugin {
  static const MethodChannel _channel =
      const MethodChannel('sfplugin');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
