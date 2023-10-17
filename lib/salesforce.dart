import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class SalesforcePlugin {

  factory SalesforcePlugin() {
    _singleton ??= SalesforcePlugin._(const MethodChannel('com.salesforce.flutter.SalesforcePlugin'));
    return _singleton!;
  }

  SalesforcePlugin._(MethodChannel channel) : _channel = channel;

  static SalesforcePlugin? _singleton;

  static SalesforcePlugin get _platform => SalesforcePlugin.instance;

  static SalesforcePlugin _instance = SalesforcePlugin();
  static SalesforcePlugin get instance => _instance;

  final MethodChannel _channel;
  static String _apiVersion = 'v52.0';

  /*
   * Set apiVersion to be used
  */
  void setApiVersion(String apiVersion) => _apiVersion = apiVersion;

  /*
   * Return apiVersion used
  */
  static String get getApiVersion => _apiVersion;

  /*
   * Network methods
   */

  /*
   * Send arbitrary force.com request
   * @param endPoint
   * @param path
   * @param method
   * @param payload
   * @param headerParams
   * @param fileParams  Expected to be of the form: {<fileParamNameInPost>: {fileMimeType:<someMimeType>, fileUrl:<fileUrl>, fileName:<fileNameForPost>}}
   * @param returnBinary When true response returned as {encodedBody:"base64-encoded-response", contentType:"content-type"}
  */

  static Future<Map> sendRequest({String endPoint = '/services/data', String path = '', String method = 'GET', Map? payload, Map? headerParams, Map? fileParams, bool returnBinary = false}) async {
    final Object response = await _platform._channel.invokeMethod(
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
    final responseBody = response is Map ? response : json.decode(response.toString());
    return responseBody is List ? Map.fromIterable(responseBody) : responseBody;
  }

  /*
   * Lists summary information about each Salesforce.com version currently
   * available, including the version, label, and a link to each version's
   * root.
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> versions() => sendRequest(path: '/');

  /*
   * Lists available resources for the client's API version, including
   * resource name and URI.
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> resources() => sendRequest(path: '/$_apiVersion/');

  /*
   * Lists the available objects and their metadata for your organization's
   * data.
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> describeGlobal() => sendRequest(path: '/$_apiVersion/sobjects/');

  /*
   * Describes the individual metadata for the specified object.
   * @param objtype object type; e.g. "Account"
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> metadata(String objtype) => sendRequest(path: '/$_apiVersion/sobjects/sobjects/$objtype/');

  /*
   * Completely describes the individual metadata at all levels for the
   * specified object.
   * @param objtype object type; e.g. "Account"
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> describe(String objtype) => sendRequest(path: '/$_apiVersion/sobjects/sobjects/$objtype/describe/');

  /*
   * Fetches the layout configuration for a particular sobject type and record type id.
   * @param objtype object type; e.g. "Account"
   * @param (Optional) recordTypeId Id of the layout's associated record type
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> describeLayout(String objtype, {String recordTypeId = ''}) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/describe/layouts/$recordTypeId');

  /*
   * Creates a new record of the given type.
   * @param objtype object type; e.g. "Account"
   * @param fields an object containing initial field names and values for
   *               the record, e.g. {:Name "salesforce.com", :TickerSymbol
   *               "CRM"}
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> create(String objtype, Map fields) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/', method: 'POST', payload: fields);

  /*
   * Retrieves field values for a record of the given type.
   * @param objtype object type; e.g. "Account"
   * @param id the record's object ID
   * @param [fields=null] optional comma-separated list of fields for which
   *               to return values; e.g. Name,Industry,TickerSymbol
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> retrieve(String objtype, String id, Map fields) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/$id', method: 'GET', payload: fields);

  /*
   * Upsert - creates or updates record of the given type, based on the
   * given external Id.
   * @param objtype object type; e.g. "Account"
   * @param externalIdField external ID field name; e.g. "accountMaster__c"
   * @param externalId the record's external ID value
   * @param fields an object containing field names and values for
   *               the record, e.g. {:Name "salesforce.com", :TickerSymbol
   *               "CRM"}
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> upsert(String objtype, String externalIdField, String? externalId, Map fields) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/$externalIdField/${externalId ?? ''}', method: externalId != null ? "PATCH" : "POST", payload: fields);

  /*
   * Updates field values on a record of the given type.
   * @param objtype object type; e.g. "Account"
   * @param id the record's object ID
   * @param fields an object containing initial field names and values for
   *               the record, e.g. {:Name "salesforce.com", :TickerSymbol
   *               "CRM"}
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> update(String objtype, String id, Map fields) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/$id', method: "PATCH", payload: fields);

  /*
   * Deletes a record of the given type. Unfortunately, 'delete' is a
   * reserved word in JavaScript.
   * @param objtype object type; e.g. "Account"
   * @param id the record's object ID
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> del(String objtype, String id) => sendRequest(path: '/$_apiVersion/sobjects/$objtype/$id', method: "DELETE");

  /*
   * Executes the specified SOQL query.
   * @param soql a string containing the query to execute - e.g. "SELECT Id,
   *             Name from Account ORDER BY Name LIMIT 20"
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> query(String soql) => sendRequest(path: "/$_apiVersion/query", payload: {'q': soql});

  /*
   * Queries the next set of records based on pagination.
   * <p>This should be used if performing a query that retrieves more than can be returned
   * in accordance with http://www.salesforce.com/us/developer/docs/api_rest/Content/dome_query.htm</p>
   * @param url - the url retrieved from nextRecordsUrl or prevRecordsUrl
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> queryMore(String url) => sendRequest(endPoint: '',  path: url.split('/https:\/\/[^/]*(.*)/').last);

  /*
   * Executes the specified SOSL search.
   * @param sosl a string containing the search to execute - e.g. "FIND
   *             {needle}"
   * @param callback function to which response will be passed
   * @param [error=null] function called in case of error
  */
  static Future<Map> search(String soql) => sendRequest(path: "/$_apiVersion/search", payload: {'q': soql});

  /*
   * Convenience function to retrieve an attachment
   * @param id
   * @param callback function to which response will be passed (attachment is returned as {encodedBody:"base64-encoded-response", contentType:"content-type"})
   * @param [error=null] function called in case of error
  */
  static Future<Map> getAttachment(String id) => sendRequest(path: "/$_apiVersion/sobjects/Attachment/$id/Body", method: 'GET', returnBinary: true);


  /*
   * Oauth methods
   */

  /*
   * Obtain authentication credentials.
   *   success - The success callback function to use.
   *   fail    - The failure/error callback function to use.
   * Returns a dictionary with:
   *   accessToken
   *   refreshToken
   *   clientId
   *   userId
   *   orgId
   *   loginUrl
   *   instanceUrl
   *   userAgent
   *   community id
   *   community url
   */
  static Future<Map> getAuthCredentials() async {
    final Object? response = await _platform._channel.invokeMethod(
        'oauth#getAuthCredentials'
    );
    return response is Map ? response : json.decode(response?.toString() ?? '');
  }

  static Future<Object> getClientInfo() async {
    final Object response = await _platform._channel.invokeMethod(
        'oauth#getClientInfo'
    );
    return response;
  }

  static Future<void> authenticate() async {
    await _platform._channel.invokeMethod('oauth#authenticate');
  }

  static Future<void> logoutCurrentUser() async {
    await _platform._channel.invokeMethod('oauth#logoutCurrentUser');
  }

  static Future<Map> registerForNotifications(String token, String? communityId, String packageName) async {
    final Map<String, dynamic> fields = {
      "ConnectionToken": token,
      "ServiceType": "androidGcm",
      "ApplicationBundle": packageName,
    };
    if (communityId != null){
      fields["NetworkId"] = communityId;
    }
    return await SalesforcePlugin.create("MobilePushServiceDevice", fields);
  }

}