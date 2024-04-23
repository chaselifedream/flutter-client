// Copyright 2020 Chase S. All rights reserved.
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/integrations/spotify_connector.dart';
import 'package:tunestack_flutter/integrations/amplitude_connector.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/screens/auth/login_screen.dart';
import 'package:tunestack_flutter/screens/auth/register_screen.dart';
import 'package:tunestack_flutter/screens/bottom_nav_screen.dart';

void main() => runApp(TunestackApp());

class TunestackApp extends StatefulWidget {
  @override
  _TunestackAppState createState() => _TunestackAppState();
}

class _TunestackAppState extends State<TunestackApp> {
  _TunestackAppState() {
    _userModel = UserModel();
    _spotifyConnector = SpotifyConnector();
  }

  UserModel _userModel;
  ReviewModel _followingReviews;
  ReviewModel _recommendedReviews;
  SpotifyConnector _spotifyConnector;
  AmplitudeConnector _amplitudeConnector;
  //Amplitude analytics;

  @override
  void initState() {
    super.initState();

    _amplitudeConnector = AmplitudeConnector();
  }

  /// Return true to indicate the async operation is complete
  Future<bool> init() async {
    List<Future<dynamic>> futures = <Future<dynamic>>[
      // All API calls rely on user authentcation data
      _userModel.init(),
      _spotifyConnector.init()
    ];
    final List<dynamic> results = await Future.wait<dynamic>(futures);

    // true if user is currently logged in
    if (results[0] == true) {
      _followingReviews = ReviewModel(_userModel.idToken);
      _recommendedReviews = ReviewModel(_userModel.idToken);

      // '/review' API requires idToken
      futures = <Future<dynamic>>[
        _followingReviews.loadFollowing(_userModel.id),
        _recommendedReviews.loadRecs()
      ];
      await Future.wait<dynamic>(futures);

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: init(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // User model initialized
        if (snapshot.hasData) {
          // Using MultiProvider is convenient when providing multiple objects.
          return MultiProvider(
            providers: <SingleChildWidget>[
              // Provider calls build() only one time
              Provider<UserModel>(create: (BuildContext context) => _userModel),
              Provider<SpotifyConnector>(create: (BuildContext context) => _spotifyConnector),
              Provider<AmplitudeConnector>(create: (BuildContext context) => _amplitudeConnector),
              Provider<HomeTabReviews>(create: (BuildContext context) => HomeTabReviews(_followingReviews, _recommendedReviews))
            ],
            child: MaterialApp(
              title: 'Tunestack',
              theme: appTheme,
              routes: <String, Widget Function(BuildContext)>{
                '/': (BuildContext context) => (snapshot.data == true) ? BottomNavScreen() : LoginScreen(),
                '/auth/login': (BuildContext context) => LoginScreen(),
                '/auth/register': (BuildContext context) => RegisterScreen(),
                '/bottom_nav': (BuildContext context) => BottomNavScreen()
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}
