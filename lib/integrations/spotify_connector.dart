import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tunestack_flutter/common/secure_storage.dart';
import 'package:tunestack_flutter/common/utility.dart';

/// Talk to Spotify through Tunestack backend
class _SpotifyAuthServer {
  static const String _baseUrl = 'https://a5wsem2rb8.execute-api.us-east-1.amazonaws.com/latest';

  static Future<String> getClientCredentialsAuth() async {
    final SecureStorage secureStorage = SecureStorage();
    String accessToken = await secureStorage.getClientCredentialsAuth();

    // No accessToken was stored or it's expired. Get a new token.
    if (accessToken == null) {
      final http.Response response = await http.get(
        '$_baseUrl/client-credentials'
      );

      //{"access_token":"xxx", "token_type":"Bearer", "expires_in":3600, "scope":""}
      final dynamic auth = json.decode(response.body);
      accessToken = auth['access_token'] as String;

      await secureStorage.storeClientCredentialsAuth(accessToken, auth['expires_in'] as int);
    }

    return accessToken;
  }

}

class SpotifyConnector {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  String accessToken;
  final List<dynamic> _albums = <dynamic>[];
  final List<dynamic> _artists = <dynamic>[];

  /// Initialize Spotify connector
  Future<void> init() async {
    accessToken = await _SpotifyAuthServer.getClientCredentialsAuth();
    print('Spotify client creds: $accessToken');
  }

  Future<void> search(final String query) async {
    final String endpointPath = '$_baseUrl/search?q=$query&type=album,artist&limit=10';
    final http.Response response = await http.get(
      endpointPath,
      headers: <String, String> {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    );

    // Refer to Spotify API doc for response structure
    // https://developer.spotify.com/documentation/web-api/reference/search/search/
    final dynamic rawResult = json.decode(utf8.decode(response.bodyBytes));

    _albums.clear();
    _albums.addAll(rawResult['albums']['items'] as Iterable<dynamic>);
    _artists.clear();
    _artists.addAll(rawResult['artists']['items'] as Iterable<dynamic>);
  }

  int albumListLen() {
    return _albums.length;
  }

  int artistsListLen() {
    return _artists.length;
  }

  /// [large] is true if we want to get the large image, normally used for background.
  /// small image is normal used as avatar
  String albumImageUrl(int index, {bool large = true}) {
    if (large == true) {
      return _albums[index]['images'][0]['url'] as String;
    }
    else {
      // Last image has the smallest width
      return _albums[index]['images'].last['url'] as String;
    }
  }

  String albumId(int index) {
    return _albums[index]['id'] as String;
  }

  String albumName(int index) {
    return _albums[index]['name'] as String;
  }

  String albumArtistName(int index) {
    return _albums[index]['artists'][0]['name'] as String;
  }

  /// _artists[index]['images'][0]['url'] has the largeest image, used for background.
  /// _artists[index]['images'].last['url'] has the smallest image, used as avatar.
  String artistsImageUrl(int index) {
    // Use safeAccess because some artists don't have images.
    // Access _artists[index]['images'][0]['url']
    return Utility.safeAccess(_artists, <dynamic>[index, 'images', 0, 'url'], null) as String;
  }

  String artistName(int index) {
    return _artists[index]['name'] as String;
  }
}
