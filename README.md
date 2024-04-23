# Tunestack

Tunestack frontend via Flutter

## Getting Started

* Install Flutter framework - https://flutter.dev/docs/get-started/install
* Install pacakges - 'flutter pub get'
* 'flutter_aws_amplify_cognito' package requires a valid awsconfiguration.json:
https://agnostech.github.io/flutteramplify/#/authentication?id=getting-started
A pre-built awsconfiguration.json was committed in this private repo.
* Run the app - 'flutter run' // It will take longer the first time
* Good explanations of Provider package:
https://medium.com/flutter-community/making-sense-all-of-those-flutter-providers-e842e18f45dd

## Testing

Address all the warnings and errors - 'flutter analyze'

### Unit and Widget testing

* Run all unit test cases - 'flutter test'

### Integration testing

* Requires a real device or simulator
* Run all test cases in a test file (user.dart in this case) - 'flutter  drive --target=test_driver/user.dart'

### TODO

* Run test without mobile device or simulator
    * Set up Flutter Desktop - https://flutter.dev/desktop
    * Speed up the integration testing - https://medium.com/flutter-community/blazingly-fast-flutter-driver-tests-5e375c833aa
    * I couldn't make this work yet. Seems Xcode is required and there might be some issues with Flutter plugins used by Tunestack

## Design

When the app is initialized, main.dart will look up user data. If the user is already logged in, the app navigates to the home screen. Otherwise, the app navigates to the login screen. User data can be access through the provider package:

`UserModel userModel = Provider.of<UserModel>(context, listen: false);`

### Bottom Tab navigation

Each tab is lazy loading and has its own navigation stack.

Inspired by:
* https://edsonbueno.com/2020/01/23/bottom-navigation-in-flutter-mastery-guide/
* https://medium.com/flutter-community/navigate-without-context-in-flutter-with-a-navigation-service-e6d76e880c1c
* https://medium.com/flutter-community/flutter-push-pop-push-1bb718b13c31