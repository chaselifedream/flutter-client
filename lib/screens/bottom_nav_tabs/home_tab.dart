import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/common/widget/feed_container.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String tab;
  PageController followingController = PageController();
  PageController foryouController = PageController();
  @override
  void initState() {
    tab = 'ForYou';
    super.initState();
  }

  TextStyle tabStyle = const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black);

  Widget _getTabBody(final UserModel userModel, final ReviewModel followingReviews, final ReviewModel recommendedReviews) {
    if (tab == 'Following') {
      return PageView.builder(
        key: const PageStorageKey<String>('following'),
        scrollDirection: Axis.vertical,
        controller: followingController,
        itemCount: followingReviews.listLen(),
        itemBuilder: (BuildContext context, int index) {
          return FeedContainer(
            review: Review(followingReviews, index),
            userModel: userModel,
            parentScrollController: followingController,
          );
        },
      );
    } else {
      return PageView.builder(
        key: const PageStorageKey<String>('foryou'),
        scrollDirection: Axis.vertical,
        controller: foryouController,
        itemCount: recommendedReviews.listLen(),
        itemBuilder: (BuildContext context, int index) {
          return FeedContainer(
            review: Review(recommendedReviews, index),
            userModel: userModel,
            parentScrollController: foryouController,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final HomeTabReviews homeTabReviews = Provider.of<HomeTabReviews>(context, listen: false);
    final ReviewModel followingReviews = homeTabReviews.followingReviews;
    final ReviewModel recommendedReviews = homeTabReviews.recommendedReviews;
    debugPrint('HomeTab.build()');

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: GestureDetector(
              onDoubleTap: () {
                if (tab == 'Following') {
                  followingController.animateToPage(0, duration: kTabScrollDuration, curve: Curves.linear);
                } else {
                  foryouController.animateToPage(0, duration: kTabScrollDuration, curve: Curves.linear);
                }
              },
              child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: tab,
                  children: <String, Widget>{
                    'ForYou': Container(
                        child: Center(child: Text('For You', style: tabStyle)),
                        width: MediaQuery.of(context).size.width * .45),
                    'Following': Text('Following', style: tabStyle)
                  },
                  onValueChanged: (String changed) => setState(() {
                        tab = changed;
                      })),
            )),
        body: _getTabBody(userModel, followingReviews, recommendedReviews));
  }
}
