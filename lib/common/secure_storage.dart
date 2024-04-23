import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';

/// Store data in secure storage
/// 
/// Extend CognitoStorage with FlutterSecureStorage to persist account
/// login sessions
class SecureStorage extends CognitoStorage {
  SecureStorage() {
     _storage = const FlutterSecureStorage();
  }

  FlutterSecureStorage _storage;

  @override
  Future<String> getItem(String key) async {
    final String value = await _storage.read(key: key);

    return value;
  }

  @override
  Future<String> setItem(String key, dynamic value) async {
    await _storage.write(key: key, value: value as String);
    return getItem(key);
  }

  @override
  Future<String> removeItem(String key) async {
    final Future<String> item = getItem(key);
    if (item != null) {
      await _storage.delete(key: key);
      return item;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Store the access token and expiry from Spotify's Client Credentials Flow
  ///
  /// [expiresIn] is in seconds
  Future<void> storeClientCredentialsAuth(String accessToken, int expiresIn) async {
    final int expiry = DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;

    await _storage.write(key: 'ClientCredentialsAuth', value: accessToken);
    await _storage.write(key: 'ClientCredentialsExpiry', value: expiry.toString());
  }

  /// Return the access toke if it doesn't expire yet
  Future<String> getClientCredentialsAuth() async {
    final int curTime = DateTime.now().millisecondsSinceEpoch;
    int expiry;

    try {
      expiry = int.parse(await _storage.read(key: 'ClientCredentialsExpiry'));
    } catch (e) {
      // No client credentials stored or int conversion failed
      print('Error reading expiry');
      return null;
    }

    if (curTime < expiry) {
      final String auth = await _storage.read(key: 'ClientCredentialsAuth');
      return auth;
    } else {
      return null;
    }
  }
}
