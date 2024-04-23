import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/common/widget/profile/profile_header.dart';
import 'package:tunestack_flutter/common/widget/profile/profile_feed.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    @required this.bottomNavContext,
    @required this.user,
    Key key,
  }) : super(key: key);
  final UserModel user;
  final BuildContext bottomNavContext; // Context from BottomNavScreen
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<bool> _reviewFuture;
  ReviewModel _myReviews;
  UserModel _userModel;
  UserModel user;

  @override
  void initState() {
    super.initState();

    _userModel = Provider.of<UserModel>(widget.bottomNavContext, listen: false);
    user = widget.user ?? _userModel;
    _myReviews = ReviewModel(_userModel.idToken);
    _reviewFuture = _myReviews.loadMyReviews(user.id);
  }

  AppBar appBar(bool isCurrentUser){
    if(isCurrentUser){
      return AppBar(
        title: Text(user.username, style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black)
      );
    }
    else{
      return AppBar(
        title: Text(user.username, style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      );
    }
  }

  Drawer createEndDrawer(bool isCurrentUser){
    if(isCurrentUser){
      return Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text("Discover People"),
              onTap: (){
              }
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              }
            ),
            Divider()]));}
    else{
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileTab.build()');

    return Scaffold(
      appBar: appBar(user.name == _userModel.name),
      endDrawer: createEndDrawer(user.name == _userModel.name),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(child: ProfileHeader(userModel: user, reviews: _myReviews)),
          FutureBuilder<bool>(
            future: _reviewFuture,
            builder: (_, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data == true)
                return Container(
                  decoration: new BoxDecoration(color: Colors.white),
                  child: ProfileFeed(reviews: _myReviews, userModel: user));
              else
                return const Center(child: CircularProgressIndicator());
              }
          ),
        ]),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({ @required this.user,
    Key key,
  }) : super(key: key);
  final UserModel user;

  Future<void> signOut(BuildContext context, UserModel user) async {
    await user.signOut();

    // Remove all routes in the root navigator so that a user can't back-button to
    // those route screens after logging out. Use rootNavigator because we want to
    // push the login screen into MaterialApp/CupertinoApp's navigator, not into
    // the current/inner tab screen navigator.
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil<dynamic>('/auth/login', (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
      final UserModel _user = Provider.of<UserModel>(context, listen: false);    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text("Settings", style: TextStyle(color: Colors.black)),
      ),
      body:
        Container( 
          child: Container(
            child: Container(
              child: ListView(
                children: <Widget>[
                  Text("Notifications"),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Enable Notifications"),
                        Switch(
                          value: true,
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                          // onChanged: (value) {
                          //   setState(() {
                          //     isSwitched = value;
                          //     print(isSwitched);
                          //   });
                          // },
                        )
                      ]
                    ),
                  ),
                  Divider(),
                  Text("Other"),
                  Divider(),
                  ListTile(
                    title: Text("Contact Support"),
                    onTap: (){
                      launch('https://tunestack.fm/support');
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    title: Text("Report Abuse"),
                    onTap: (){
                      launch('https://tunestack.fm/report-abuse');
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    title: Text("Terms & Conditions"),
                    onTap: (){
                      launch('https://tunestack.fm/terms');
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    title: Text("Privacy Policy"),
                    onTap: (){
                      launch('https://tunestack.fm/privacy');
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    title: Text('Logout'),
                    onTap: () {
                      // Navigator.pop(context);
                      signOut(context, _user);
                    },
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),

            )
          )
        )
    );
  }
}
