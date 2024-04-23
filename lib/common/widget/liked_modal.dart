import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/models/like.dart';
import 'package:tunestack_flutter/models/review.dart';

class LikedModal extends StatefulWidget {
  const LikedModal({
    @required this.review,
    Key key,
  }) : super(key: key);

  final Review review;

  @override
  _LikedModalState createState() => _LikedModalState();
}

class _LikedModalState extends State<LikedModal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Like> likes = widget.review.likes;
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(12))),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '👏 APPLAUSE FROM',
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 12
              ),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final Like like = likes[index];
                return Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(like.imageUrl ?? placeholderProfileUrl),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      like.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: null,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(242, 242, 242, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0))),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 7.0),
                          child: Center(
                              child: Text('Follow',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black))),
                        ),
                      )),
                  ],
                );
              }, 
              separatorBuilder: (_, int index) => const SizedBox(height: 10), 
              itemCount: likes.length
            )
            ]
        ),
      ),
    );
  }
}
