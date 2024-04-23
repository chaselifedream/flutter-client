import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/common/widget/explore/explore_container.dart';
import 'package:tunestack_flutter/models/review.dart';



class ExploreTab extends StatelessWidget {

  Future<void> signOut(BuildContext context) async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    //await userModel.signOut();
    // For some reason signOut hangs in flutter_aws_amplify_cognito or AWS SDK layer.
    // If we do 'await', it got stuck. Here we don't wait and navigate to the login
    // screen. The credentials and user state are reset correctly with the workaround
    userModel.signOut();

    Navigator.pushReplacementNamed(context, '/auth/login');
  }
  PageController controller;


  Widget _getTabBody(final UserModel userModel, final ReviewModel reviews){
    return ListView.builder(
      controller: controller,
      // physics: const PageScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: reviews.listLen(),
      itemBuilder: (BuildContext context, int index) {
        final Review review = Review(reviews, index);
        return ExploreContainer(
          review: review,
          userModel: userModel,
        );
      },
);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ExploreTab.build()');

    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final HomeTabReviews homeTabReviews = Provider.of<HomeTabReviews>(context, listen: false);
    final ReviewModel reviews = homeTabReviews.recommendedReviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(color: Colors.black))
      ),
      body: _getTabBody(userModel, reviews));
  }
}