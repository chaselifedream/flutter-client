import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/common/widget/album_widget.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/tag.dart';
import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/profile_tab.dart';

class ExploreContainer extends StatelessWidget {
  const ExploreContainer({
    @required this.review,
    @required this.userModel,
    Key key,
  }) : super(key: key);

  final Review review;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: <Widget> [
          ClipRect(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(review.albumImageUrl ?? placeholderProfileUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                  height: MediaQuery.of(context).size.width * 0.50,
                  width: MediaQuery.of(context).size.width * 0.35,
                ),
              ),
            ),
          ),
          Container(
            child: Stack(
              children: <Widget>[Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.width * 0.20,
                          width: MediaQuery.of(context).size.width * 0.20,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(review.albumImageUrl ?? placeholderProfileUrl),
                              fit: BoxFit.contain
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                        Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.005),
                          child: Text(
                            review.albumName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.005, vertical:MediaQuery.of(context).size.width * 0.005 ),
                          child: Text(
                            '${review.tracks.length > 1 ? 'Album' : 'Song'} by '
                            '${review.artistName} • ${review.albumYear}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 8, color: Colors.white)
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                        Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 8,
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.white),
                                ),
                              ),
                            ]
                          )
                      ],
                    ),
                  ),
                ]
              ),]
            )
          )
        ]
      )
    );
  }
}
