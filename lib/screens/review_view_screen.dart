import 'package:flutter/material.dart';
import 'package:tunestack_flutter/common/widget/feed_container.dart';
import 'package:tunestack_flutter/models/review.dart';

/// Where a user can see a review from another user
class ReviewViewScreen extends StatelessWidget {
  const ReviewViewScreen({
    @required this.model,
    @required this.index,
    Key key,
  })  : assert(index != null),
        super(key: key);

  final ReviewModel model;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Review review = Review(model, index);
    return Scaffold(
        appBar: AppBar(title: Text(review.albumName)), body: FeedContainer(review: review, userModel: review.user, parentScrollController: null));
  }
}
