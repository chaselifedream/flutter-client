import 'package:amplitude_flutter/amplitude.dart';

class AmplitudeConnector {
  AmplitudeConnector() {
    _analytics = Amplitude.getInstance();
    // Initialize SDK
    _analytics.init(_apiKey);
    // Enable COPPA privacy guard, not to report sensitive user information.
    _analytics.enableCoppaControl();
    // Turn on automatic session events
    _analytics.trackingSessionEvents(true);

    _analytics.logEvent('tunestack_app startup');

    print('AmplitudeConnector initialized');
  }

  static const String _apiKey = 'ba0481b552621988346ae7d6be169ba8';
  Amplitude _analytics;

  /// Identify the user with username
  void identifyUser(final String userId) {
    _analytics.setUserId(userId);
  }

  void signUpEvent() {
    _analytics.logEvent('SignUp');    
  }
}