import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import 'package:tunestack_flutter/common/base_model.dart';
import 'package:tunestack_flutter/common/secure_storage.dart';
import 'package:tunestack_flutter/common/theme.dart';

/// Manage a user's data, from both Cognito and our backend database
class UserModel extends BaseModel {
  UserModel({Map<String, dynamic> userData})
      : _attributes = <String, String>{},
        _userData = userData,
        super('user');

  static const String _awsUserPoolId = 'us-east-1_oJicKkBoF';
  static const String _awsClientId = 'oltv5jk99vp24so3jrhc1vlkb';
  static const String _identityPoolId = 'us-east-1:e7399785-98ce-4bfd-9198-bd97b65cae29';

  final CognitoUserPool _userPool = CognitoUserPool(_awsUserPoolId, _awsClientId);
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  CognitoCredentials _credentials;
  String _idToken;

  /// Cognito user attributes
  Map<String, String> _attributes;

  /// User data from our backend database
  Map<String, dynamic> _userData;

  String get idToken => _idToken;
  String get id => _attributes['sub'] ?? _userData['id'] as String;
  String get imageUrl => _userData['spotifyImageUrl'] as String ?? placeholderProfileUrl;
  // username originally from Cognito user attributes and saved into backend
  // database.
  String get username => _userData['username'] as String;
  String get name => _userData['name'] as String;
  String get bio => _userData['bio'] as String;
  

  /// Convert from [{"Name":"phone_number", "Value":"123456789"}, ...] to
  /// {"phone_number": "123456789", ....}
  Map<String, String> _extractAttributes(List<CognitoUserAttribute> attributesList) {
    final Map<String, String> attributes = <String, String>{};

    for (int i = 0; i < attributesList.length; i++) {
      attributes[attributesList[i].getName()] = attributesList[i].getValue();
    }

    return attributes;
  }

  /// Populate user attributes from Cognito and user data from backend database
  Future<void> _populateUserData() async {
    // Get user's Cognito attributes
    final List<CognitoUserAttribute> attributeList = await _cognitoUser.getUserAttributes();
    _attributes = _extractAttributes(attributeList);

    // Retrieve user credentials -- for use with other AWS services
    _credentials = CognitoCredentials(_identityPoolId, _userPool);
    _idToken = _session.getIdToken().getJwtToken();
    await _credentials.getAwsCredentials(_idToken);
    setAwsSigV4Client(_credentials, _idToken);

    // Get user's data from backend database
    _userData = await get(subPath: id);
  }

  /// Initialize UserModel data.
  Future<bool> init() async {
    final SecureStorage secureStorage = SecureStorage();
    _userPool.storage = secureStorage;

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      return false;
    }

    _session = await _cognitoUser.getSession();
    if (_session.isValid() == false) {
      print('init - invalid session');
      return false;
    }

    // Initialization completes sucessfully
    await _populateUserData();
    return true;
  }

  /// Initiate password resetting flow by sending a verification code to the user
  Future<String> resetPwdSendCode(final String username) async {
    _cognitoUser = CognitoUser(username, _userPool);

    // format: {CodeDeliveryDetails: {AttributeName: email, DeliveryMedium: EMAIL, Destination: a***@b***.com}}
    Map<String, dynamic> data;
    try {
      data = await _cognitoUser.forgotPassword() as Map<String, dynamic>;
    } catch (e) {
      print(e);
    }

    return data['CodeDeliveryDetails']['Destination'] as String;
  }

  /// 2nd step of password resetting flow - User verifies the code
  Future<bool> resetPwdVerifyCode(final String code, final String password) async {
    bool passwordConfirmed = false;

    try {
      passwordConfirmed = await _cognitoUser.confirmPassword(code, password);
    } catch (e) {
      print(e);
    }

    return passwordConfirmed;
  }

  Future<bool> signIn(final String username, final String password) async {
    _cognitoUser = CognitoUser(username, _userPool, storage: _userPool.storage);

    final AuthenticationDetails authDetails = AuthenticationDetails(username: username, password: password);

    try {
      _session = await _cognitoUser.authenticateUser(authDetails);
    } catch (e) {
      print(e);
      return false;
    }

    if (_session.isValid() == false) {
      print('signIn - invalid session');
      return false;
    }

    // Signed in successfully
    await _populateUserData();
    return true;
  }

  Future<void> signOut() async {
    if (_credentials != null) {
      await _credentials.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      await _cognitoUser.signOut();
    }
  }

  /// Sign up and create a Cognito user
  Future<String> signUp(final String username, final String password, final String email) async {
    final List<AttributeArg> userAttributes = <AttributeArg>[
      AttributeArg(name: 'name', value: username),
      AttributeArg(name: 'email', value: email),
      // The current Cognito pool requires a phone number
      const AttributeArg(name: 'phone_number', value: '+10000000000')
    ];

    try {
      await _userPool.signUp(username, password, userAttributes: userAttributes);
    } catch (error) {
      if (error?.name == 'UsernameExistsException') {
        return 'Username already exists';
      }
      if (error?.name == 'InvalidPasswordException' || error.name == 'InvalidParameterException') {
        return error.message as String;
      }
      // For all other errors we show a generic message
      print('Signup $error');
      return 'Signup failed';
    }

    return 'Success';
  }
}
