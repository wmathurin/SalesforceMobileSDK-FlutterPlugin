import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class SalesforcePlugin {
  static String apiVersion = 'v42.0';

  static const MethodChannel _channel =
  const MethodChannel('sfplugin');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  /**
   * Send arbitrary force.com request
   * @param endPoint
   * @param path
   * @param method
   * @param payload
   * @param headerParams
   * @param fileParams  Expected to be of the form: {<fileParamNameInPost>: {fileMimeType:<someMimeType>, fileUrl:<fileUrl>, fileName:<fileNameForPost>}}
   * @param returnBinary When true response returned as {encodedBody:"base64-encoded-response", contentType:"content-type"}
   */
  static Future<Object> sendRequest({String endPoint : "/services/data", String path, String method : "GET", Map payload : null, Map headerParams : null, Map fileParams : null, bool returnBinary : false}) async {
    final Object response = await _channel.invokeMethod(
        'network#sendRequest',
        <String, dynamic>{
          'endPoint': endPoint,
          'path': path,
          'method': method,
          'queryParams': payload,
          'headerParams': headerParams,
          'fileParams': fileParams,
          'returnBinary': returnBinary}
    );
    return response is Map ? response : JSON.decode(response);
  }

  static Future<Map> query(String soql) => sendRequest(path: "/${apiVersion}/query", payload: {'q': soql});
}
