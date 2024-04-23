import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tunestack_flutter/common/widget/feed_container.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';

class ProfileFeed extends StatelessWidget {
  const ProfileFeed({
    @required this.reviews,
    @required this.userModel,
    Key key,
  }) : super(key: key);

  final ReviewModel reviews;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List<Widget>.generate(reviews.listLen(), (int index) {
          final Review review = Review(reviews, index);
          return GestureDetector(
            onTap: () => Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) =>
                        ProfileReviews(reviews: reviews, initialIndex: index, userModel: userModel))),
            child: Container(
              decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(review.albumImageUrl))),
            ),
          );
        }));
  }
}

class ProfileReviews extends StatefulWidget {
  const ProfileReviews({@required this.reviews, @required this.initialIndex, @required this.userModel, Key key})
      : super(key: key);

  final ReviewModel reviews;
  final int initialIndex;
  final UserModel userModel;

  @override
  _ProfileReviewsState createState() => _ProfileReviewsState();
}

class _ProfileReviewsState extends State<ProfileReviews> {
  PageController controller;
  @override
  void initState() {
    controller = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel _userModel = Provider.of<UserModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${widget.userModel == null ? widget.userModel.username : _userModel.username}'s reviews",
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: PageView.builder(
        controller: controller,
        physics: const PageScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: widget.reviews.listLen(),
        itemBuilder: (BuildContext context, int index) {
          final Review review = Review(widget.reviews, index);
          return FeedContainer(
            review: review,
            userModel: _userModel,
            parentScrollController: controller,
          );
        }
      ),
    );
  }
}
