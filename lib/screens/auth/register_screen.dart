import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/integrations/amplitude_connector.dart';


class RegisterScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp(BuildContext context) async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String email = emailController.text;

    final String result = await userModel.signUp(username, password, email);

    if (result != 'Success') {
      final SnackBar snackBar = SnackBar(
        key: const Key('snackbar_register'),
        content: Text(result)
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);

      return;
    }

    // Identify the username and send signUp event to Amplitude
    final AmplitudeConnector amplitudeConnector = Provider.of<AmplitudeConnector>(context, listen: false);
    amplitudeConnector.identifyUser(username);
    amplitudeConnector.signUpEvent();

    // Successful account creation, sign in the user
    final bool signedIn = await userModel.signIn(username, password);

    if (signedIn == true) {
      Navigator.pushReplacementNamed(context, '/bottom_nav');
    }
    else {
      throw Exception('Should not happen - sign-in after sign-up failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('screen_register'),
      appBar: AppBar(
        leading: const BackButton(
          key: Key('backbutton_register')
        ), 
        title: const Text('Create an account'),
        backgroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 48),
            const Text('💚', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Image(image: AssetImage('assets/images/tunestack-logo-web-black.png')),
            ),
            const SizedBox(height: 8),
            const Text('write and share reviews of the music you love'),
            const SizedBox(height: 8),
            const Text('discover new music your friends are listening to'),
            const SizedBox(height: 8),
            const Text('find friends with similar taste'),
            TextFormField(
              key: const  Key('textformfield_register_username'),
              decoration: const  InputDecoration(
                hintText: 'Username',
                contentPadding: EdgeInsets.only(left:8.0)
              ),
              controller: usernameController
            ),
            TextFormField(
              key: const  Key('textformfield_register_email'),
              decoration: const  InputDecoration(
                hintText: 'Email',
                contentPadding: EdgeInsets.only(left:8.0)
              ),
              controller: emailController
            ),
            TextFormField(
              key: const Key('textformfield_register_password'),
              decoration: const InputDecoration(
                hintText: 'Password',
                contentPadding: EdgeInsets.only(left:8.0)
              ),
              controller: passwordController,
              obscureText: true,
            ),
            // Wrap RaiseButton in Builder to pass in the updated context to
            // show Snackbar in failed cases
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(
                builder: (BuildContext context) => RaisedButton(
                  key: const Key('raisedbutton_register'),
                  child: const Text('Create Account'),
                  onPressed: () {
                    signUp(context);
                  }
                )
              ),
            )
          ],
        )
      )
    );
  }
}
