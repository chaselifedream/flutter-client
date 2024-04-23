import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/integrations/amplitude_connector.dart';


enum RectStatus {
  login,
  resetPwdSendCode,
  resetPwdVerifyCode
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Hint text
  static const String _username = 'Username';
  static const String _password = 'Password';
  static const String _verifyCode = '123456';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyCodeController = TextEditingController();
  RectStatus rectStatus = RectStatus.login;
  // Where the verify code was sent to, a email address or phone number
  String _codeDestination;

  static Future<void> signIn(BuildContext context, final String username, final String password) async {
    final AmplitudeConnector amplitudeConnector = Provider.of<AmplitudeConnector>(context, listen: false);
    final HomeTabReviews homeTabReviews = Provider.of<HomeTabReviews>(context, listen: false);
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final bool signedIn = await userModel.signIn(username, password);

    if (signedIn == true) {
      // Identify the username to Amplitude
      amplitudeConnector.identifyUser(username);

      // Preload the reviews before navigating to the home screen
      final ReviewModel followingReviews = ReviewModel(userModel.idToken);
      final ReviewModel recommendedReviews = ReviewModel(userModel.idToken);
      final List<Future<dynamic>> futures = <Future<dynamic>>[
        followingReviews.loadFollowing(userModel.id),
        recommendedReviews.loadRecs()
      ];
      await Future.wait<dynamic>(futures);

      homeTabReviews.followingReviews = followingReviews;
      homeTabReviews.recommendedReviews = recommendedReviews;

      Navigator.pushReplacementNamed(context, '/bottom_nav');
    }
    else {
      const SnackBar snackBar = SnackBar(
        key: Key('snackbar_login'),
        content: Text('Login failed - Please try again')
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> resetPwdSendCode(BuildContext context) async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    _codeDestination = await userModel.resetPwdSendCode(usernameController.text);

    updateRectStatus(RectStatus.resetPwdVerifyCode);
  }

  Future<void> resetPwdVerifyCode(BuildContext context) async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final bool result = await userModel.resetPwdVerifyCode(verifyCodeController.text, passwordController.text);

    // Reset completed
    if (result == true) {
      signIn(context, usernameController.text, passwordController.text);
    }
    else {
      print('Error - Password reset failed');
      // TODO(all): Show error message
    }
  }

  final BoxDecoration textFieldBoxDecorationStyle = BoxDecoration(
    color: Colors.white.withOpacity(.2),
    borderRadius: BorderRadius.circular(5),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 1),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen.build()');
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/tunestack-login.jpg'),
          fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: const Key('screen_login'),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: kToolbarHeight * 2),
                  const Image(
                    image: AssetImage(
                      'assets/images/tunestack-logo-web-white.png')),
                  const SizedBox(height: 15),
                  Text(
                    'music with friends',
                    style: Theme.of(context).textTheme.headline1.copyWith(
                      fontWeight: FontWeight.normal, fontSize: 22),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildRect(context)
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  void updateRectStatus(RectStatus status) {
    // Don't clear because We need username to log in the user after successful password reset
    if (status != RectStatus.resetPwdVerifyCode) {
      usernameController.clear();
    }
    passwordController.clear();
    verifyCodeController.clear();

    setState(() {
      rectStatus = status;
    });
  }

  Widget buildRect(BuildContext context) {
    switch (rectStatus) {
      case RectStatus.login:
        return buildLoginRect(context);
      case RectStatus.resetPwdSendCode:
        return buildResetPwdSendCodeRect(context);
      case RectStatus.resetPwdVerifyCode:
        return buildResetPwdVerifyCodeRect(context);
      default:
        throw Exception('Unspported rectStatus: $rectStatus');
    }
  }

  /// 1st step of resetting password - Build the rect to get username
  Widget buildResetPwdSendCodeRect(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.white.withOpacity(.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildTextFormField(usernameController, _username, false),
                const SizedBox(height: 12),
                  FlatButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                        BorderRadius.circular(8)),
                    child: Container(
                      child: const Center(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey
                          )
                        )
                      ),
                      height: 40),
                    onPressed: () {
                      resetPwdSendCode(context);
                    }
                  ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Cancel',
                        recognizer: TapGestureRecognizer()..onTap = () => updateRectStatus(RectStatus.login),
                        style: const TextStyle(color: Colors.white)
                      )
                    ],
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  /// 2nd step of resetting password - Build the rect to verify code and new password
  Widget buildResetPwdVerifyCodeRect(BuildContext context) {
    final String message = 'We just sent your verification code to $_codeDestination.\nPlease enter the code below.';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.white.withOpacity(.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RichText(
                  //textAlign: TextAlign.center,
                  text:  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: message,
                        style: const TextStyle(color: Colors.white)
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                buildTextFormField(verifyCodeController, _verifyCode, false),
                const SizedBox(height: 12),
                buildTextFormField(passwordController, _password, true),
                const SizedBox(
                  height: 8,
                ),
                FlatButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(8)),
                  child: Container(
                    child: const Center(
                      child: Text(
                        'Set New Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey
                        )
                      )
                    ),
                    height: 40),
                  onPressed: () {
                    resetPwdVerifyCode(context);
                  }
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Cancel',
                        recognizer: TapGestureRecognizer()..onTap = () => updateRectStatus(RectStatus.login),
                        style: const TextStyle(color: Colors.white)
                      )
                    ],
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginRect(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.white.withOpacity(.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildTextFormField(usernameController, _username, false),
                const SizedBox(height: 12),
                buildTextFormField(passwordController, _password, true),
                const SizedBox(
                  height: 8,
                ),
                FlatButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(8)),
                  key: const Key(
                    'raisedbutton_signin'),
                  child: Container(
                    child: const Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey
                        )
                      )
                    ),
                    height: 40
                  ),
                  onPressed: () {
                    signIn(context, usernameController.text, passwordController.text);
                  }
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text:  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, '/auth/register'),
                        style: const TextStyle(color: Colors.white)
                      ),
                      TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.2),
                          fontSize: 14,
                        )
                      ),
                      TextSpan(
                        text: 'Forgot Password',
                        recognizer: TapGestureRecognizer()..onTap = () => updateRectStatus(RectStatus.resetPwdSendCode),
                        style: const TextStyle(color: Colors.white)
                      ),
                    ],
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  Container buildTextFormField(TextEditingController controller, String hintText, bool obscureText) {
    return Container(
      height: 40,
      decoration: textFieldBoxDecorationStyle,
      child: Center(
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(8,0,0,4),
            hintText: hintText,
          ),
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({
    Key key,
    @required this.boxDecorationStyle,
    @required this.controller,
  }) : super(key: key);

  final BoxDecoration boxDecorationStyle;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: boxDecorationStyle,
      child: TextFormField(
        key: const Key('textformfield_login_username'),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 8),
          hintText: 'Password',
        ),
        obscureText: true,
        controller: controller,
      ),
    );
  }
}
