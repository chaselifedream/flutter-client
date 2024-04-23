// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// Utility function to determin if a widget can be found. 
Future<bool> isPresent(SerializableFinder finder, FlutterDriver driver, {Duration timeout = const Duration(seconds: 5)}) async {
  try {
    await driver.waitFor(finder, timeout: timeout);
    return true;
  } catch (e) {
    return false;
  }
}

void main() {
  group('UserModel', () {
    const Duration signInDuration = Duration(seconds: 10);
    // Login screen widgets
    final SerializableFinder loginScreen = find.byValueKey('screen_login');
    final SerializableFinder loginUsername = find.byValueKey('textformfield_login_username');
    final SerializableFinder loginPassword = find.byValueKey('textformfield_login_password');
    final SerializableFinder loginButton = find.byValueKey('raisedbutton_signin');
    final SerializableFinder loginSnackbar = find.byValueKey('snackbar_login');
    final SerializableFinder loginSignup = find.byValueKey('text_signup');
    // Register screen widgets
    final SerializableFinder registerScreen = find.byValueKey('screen_register');
    final SerializableFinder registerBackButton = find.byValueKey('backbutton_register');
    final SerializableFinder registerUsername = find.byValueKey('textformfield_register_username');
    final SerializableFinder registerEmail = find.byValueKey('textformfield_register_email');
    final SerializableFinder registerPassword = find.byValueKey('textformfield_register_password');
    final SerializableFinder registerSnackbar = find.byValueKey('snackbar_register');
    final SerializableFinder registerButton = find.byValueKey('raisedbutton_register');
    // Home tab widgets
    final SerializableFinder homeTabPage = find.byValueKey('tab_home_page'); // The page
    // Profile tab widgets
    final SerializableFinder profileTab = find.byValueKey('tab_profile'); // The navigation tab
    final SerializableFinder profileSignoutButton = find.byValueKey('raisedbutton_profile');
    // Sign-in requires API call to backend so give longer timeout

    // A non-existng credential pair
    const String fakeUsername = 'aFakeTestUserName';
    const String fakePassword = '1Fake%TestUser+Passw0rd';
    // Real credential pair - This is a real user and only used for testing.
    // Do NOT disclose the credential to public. 
    // TODO(chase): Find a more secuire way to test the sign-in scenarios.
    const String realUsername = 'aRealTestUserName';
    const String realPassword = '#R34L%TestUser+Passw0rd';
    const String realEmail = 'aRealTestUserName@nonexist.nonexist';


    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('check flutter driver health', () async {
      final Health health = await driver.checkHealth();

      expect(health.status, HealthStatus.ok);
    });

    test('Login - A user should start at the login screen (not signed in)', () async {
      final bool isLoginScreen = await isPresent(loginScreen, driver);

      expect(isLoginScreen, true);
    });

    test('Login - Signup link navigates to the regiter screen', () async {
      await driver.tap(loginSignup); // Click 'Sign up' link

      final bool isRegisterScreen = await isPresent(registerScreen, driver);

      expect(isRegisterScreen, true);
    });

    test('Register - An existing username triggers snackbar with error messages', () async {
      await driver.tap(registerUsername);  // acquire focus
      await driver.enterText(realUsername);  // enter text
      await driver.waitFor(find.text(realUsername));  // verify text appears on UI
      await driver.tap(registerEmail);  // acquire focus
      await driver.enterText(realEmail);  // enter text
      await driver.waitFor(find.text(realEmail));  // verify text appears on UI
      await driver.tap(registerPassword);  // acquire focus
      await driver.enterText(realPassword);  // enter text
      await driver.waitFor(find.text(realPassword));  // verify text appears on UI

      await driver.tap(registerButton); // Push the button to register

      final bool isRegisterSnackbar = await isPresent(registerSnackbar, driver, timeout: signInDuration);

      expect(isRegisterSnackbar, true);
    });

    test('Register - Back button navigates to the login screen', () async {
      await driver.tap(registerBackButton); // Push back arrow at app bar

      final bool isLoginScreen = await isPresent(loginScreen, driver);

      expect(isLoginScreen, true);
    });

    test('Login - Wrong credentials trigger snackbar with error messages', () async {
      await driver.tap(loginUsername);  // acquire focus
      await driver.enterText(fakeUsername);  // enter text
      await driver.waitFor(find.text(fakeUsername));  // verify text appears on UI
      await driver.tap(loginPassword);  // acquire focus
      await driver.enterText(fakePassword);  // enter text
      await driver.waitFor(find.text(fakePassword));  // verify text appears on UI

      await driver.tap(loginButton); // Push the button to login

      final bool isLoginSnackbar = await isPresent(loginSnackbar, driver, timeout: signInDuration);

      expect(isLoginSnackbar, true);
    });

    test('Login - Successful login leads to the home screen', () async {
      await driver.tap(loginUsername);  // acquire focus
      await driver.enterText(realUsername);  // enter text
      await driver.waitFor(find.text(realUsername));  // verify text appears on UI
      await driver.tap(loginPassword);  // acquire focus
      await driver.enterText(realPassword);  // enter text
      await driver.waitFor(find.text(realPassword));  // verify text appears on UI

      await driver.tap(loginButton); // Push the button to login

      final bool isHomeTabPage = await isPresent(homeTabPage, driver, timeout: signInDuration);

      expect(isHomeTabPage, true);
    });

    test('Home - Signout navigates to the login screen', () async {
      await driver.tap(profileTab); // Navigate to 'Profile' tab
      await driver.tap(profileSignoutButton); // Push the button to sign out

      final bool isLoginScreen = await isPresent(loginScreen, driver, timeout: signInDuration);

      expect(isLoginScreen, true);
    });

  });
}