import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';

/// Implements the commone get, post, put, and delete function.
class BaseModel {
  BaseModel(String endpoint, {String idToken}) {
    _endpointPath = '${BaseModel.serverBaseUrl}/$endpoint';

    /// Except for UserModel, all model's idToken should be set when we
    /// create the model's instance
    if (idToken != null) {
      _idToken = idToken;
      _authHeader = <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $_idToken'
      };
    }
  }

  // API endpoint region
  static const String _region = 'us-east-1';
  AwsSigV4Client _awsSigV4Client;
  /// idToken must be set becore we can send requests to AWS Lambda APIs
  String _idToken;
  Map<String, String> _authHeader;


  static const String serverBaseUrl = 'https://api.tunestack.fm';
  String _endpointPath;

  void _assertAuthHeader() {
    if (_authHeader == null) {
      throw Exception('Model idToken is null');
    }
  }

  void _assertStatusCode(final http.Response response) {
    // Request failed
    if (response.statusCode > 299 || response.statusCode < 200) {
      print('Exception - ${response.statusCode} ${response.body}');
      throw Exception(response.body);
    }
  }

  /// Called by UserModel. When we create the UserModel instance, we don't know
  /// the idToken. We need to create the instance first to get the idToken from
  /// Cognito. Once we have the idToken, call this function set it.
  void setAwsSigV4Client(final CognitoCredentials credentials, final String idToken) {
    // Use 'Bearer $_idToken', instead of AWS V4 signature. When using AWS V4 signature,
    // we got {message: Unauthorized} from the API Gateway. Will need some more research.
    // Example: https://pub.dev/packages/amazon_cognito_identity_dart_2/example
    /*
    _awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId, credentials.secretAccessKey, _endpointPath,
      region: _region, sessionToken: credentials.sessionToken
    );
    */

    _idToken = idToken;
    _authHeader = <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer $_idToken'
    };

  }

  Future<Map<String, dynamic>> get({String subPath, String parameters}) async {
    _assertAuthHeader();

    String fullPath =
      (subPath == null) ? _endpointPath : '$_endpointPath/$subPath';

    if (parameters != null) {
      fullPath = '$fullPath?$parameters';
    }

    debugPrint('GET $fullPath');
    final http.Response response = await http.get(
      fullPath,
      headers: _authHeader
    );

    _assertStatusCode(response);

    return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  /// Only use this function if there is no defined Model type corresponding to the API endpoint.
  /// We should review our design carefully before deciding to use this function.
  dynamic getCustomEndpointPath(String customEndpointPath, {String parameters}) async {
    _assertAuthHeader();

    final String endpointPath = '${BaseModel.serverBaseUrl}/$customEndpointPath';
    final String fullPath = (parameters == null) ?
      endpointPath : '$endpointPath?$parameters';

    debugPrint('GET (fullPath) $fullPath');

    final http.Response response = await http.get(
      endpointPath,
      headers: _authHeader
    );

    _assertStatusCode(response);

    return json.decode(utf8.decode(response.bodyBytes)) as dynamic;
  }

  Future<dynamic> post({Object body, String subPath}) async {
    _assertAuthHeader();

    final String fullPath =
      (subPath == null) ? _endpointPath : '$_endpointPath/$subPath';

    debugPrint('POST $fullPath');
    final http.Response response = await http.post(
      fullPath,
      headers: _authHeader,
      body: json.encode(body)
    );

    _assertStatusCode(response);

    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future<dynamic> delete({String subPath}) async {
    _assertAuthHeader();

    final String fullPath =
      (subPath == null) ? _endpointPath : '$_endpointPath/$subPath';

    debugPrint('DELETE $fullPath');
    final http.Response response = await http.delete(
      fullPath,
      headers: _authHeader
    );

    _assertStatusCode(response);

    return json.decode(utf8.decode(response.bodyBytes));
  }

  void printWrapped(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
  }
}
