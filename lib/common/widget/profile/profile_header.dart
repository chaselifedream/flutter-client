import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';


class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    @required this.userModel,
    @required this.reviews,
    Key key,
  }) : super(key: key);

  final ReviewModel reviews;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    final UserModel _user = Provider.of<UserModel>(context, listen: false);

    Column buildStatColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            number.toString(),
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ))
        ],
      );
    }

    Row buildButtons(){
      if(userModel.name == _user.name){
        return Row(children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 6.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              key: const Key('raisedbutton_profile'),
              color: Colors.grey[50],
              child: const Text('Edit Profile', style: const TextStyle(fontSize: 12.0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfile()),
                );
              }
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left:6.0, top: 6.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              color: Colors.green,
              child: const Text('Invite Friends', style: const TextStyle(fontSize: 12.0, color: Colors.white)),
              onPressed: () {
                Share.share("Join me on Tunestack, a new way to find and share music. Sign up here: https://tunestack.fm/?utm_source=app&utm_medium=referral");
              }
            ),
          )
        ],);
      }
      else{
        return Row(children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 6.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              key: const Key('follow'),
              color: Colors.grey[50],
              child: const Text('Follow', style: const TextStyle(fontSize: 12.0)),
              onPressed: () {
                // TODO check for following already and add ability to follow
              }
            ),
        )]);
      }
    } 

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              if (userModel.imageUrl != null) CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.transparent,
                backgroundImage: CachedNetworkImageProvider(userModel.imageUrl),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        buildStatColumn('Reviews', reviews.listLen()),
                        buildStatColumn('Followers', 0),
                        buildStatColumn('Following', 0),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  ],
                ),
              )
            ],
          ),
          Column(children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                userModel.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            if (userModel.bio != null) Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(userModel.bio),
            ),
          ]),
          buildButtons()
        ],
      ),
    );
  }
}

class EditProfile extends StatelessWidget {
  
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
    final menuButton = new PopupMenuButton<int>(
    onSelected: (int i) {},
    itemBuilder: (BuildContext context) {},
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.center,
        child: Text("Save", style: TextStyle(color: Colors.green, fontSize: 21), textAlign: TextAlign.center)))
    );
    final UserModel _user = Provider.of<UserModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text("Edit Profile", style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          menuButton// Text("Save",  style: TextStyle(color: Colors.green, textAlign: TextAlign.center))
        ],
      ),
      body:
        Center(child:
          Column(children: <Widget>[
            CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(_user.imageUrl),
            ),
            Text("Change Photo"),
            RaisedButton(
              onPressed: () {
                // Navigator.pop(context);
                signOut(context, _user);
              },
              child: Text('Logout'),
            ),
            Text("Name"),
            Text("Bio"),
            Text("Website")
          ],)
        ));
  }
}
