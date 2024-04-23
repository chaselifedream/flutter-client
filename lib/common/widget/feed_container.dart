import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/common/widget/album_widget.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/tag.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/profile_tab.dart';

class FeedContainer extends StatelessWidget {
  const FeedContainer({
    @required this.review,
    @required this.userModel,
    @required this.parentScrollController,
    Key key,
  }) : super(key: key);

  final Review review;
  final UserModel userModel;
  final PageController parentScrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Container(height: 4, color: const Color.fromRGBO(31, 153, 120, 0.4)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 11, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.transparent,
                backgroundImage: CachedNetworkImageProvider(review.userImageUrl ?? placeholderProfileUrl),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                onTap: () => Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ProfileTab(bottomNavContext: context, user: review.user))),
                child: Text(
                  review.userName.trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: null,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 7.0),
                    child: Center(child: Text('Follow', style: TextStyle(fontSize: 12, color: Colors.black))),
                  ),
                )
              ),
              const Spacer(),
              Text(
                review.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(0, 0, 0, .5),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: review.body.trim() == '' ? const EdgeInsets.all(0) : const EdgeInsets.fromLTRB(12, 13, 17, 9),
          child: Text(
            review.body.trim() ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        if (review.tags.isNotEmpty)
          Container(
            height: 37,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 9),
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: false,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final Tag tag = review.tags[index];
                return GestureDetector(
                  onTap: null,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 242, 242, 242), borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 7.0),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: '# ',
                            style: const TextStyle(fontSize: 12, color: Color.fromRGBO(0, 0, 0, .5)),
                            children: <TextSpan>[
                              TextSpan(text: tag.name, style: const TextStyle(color: Colors.black))
                            ]
                          )
                        )
                      ),
                    ),
                  )
                );
              },
            separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 6),
            itemCount: review.tags.length),
          ),
        AlbumWidget(review: review, userModel: userModel, parentScrollController: parentScrollController),
      ]),
    );
  }
}
