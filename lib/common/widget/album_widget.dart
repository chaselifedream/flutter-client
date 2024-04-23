import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/common/widget/liked_modal.dart';
import 'package:tunestack_flutter/common/widget/play_modal.dart';
import 'package:tunestack_flutter/models/comment.dart';
import 'package:tunestack_flutter/models/like.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/user.dart';

class AlbumWidget extends StatefulWidget {
  const AlbumWidget({
    @required this.review,
    @required this.userModel,
    @required this.parentScrollController,
    Key key,
  }) : super(key: key);
  final Review review;
  final UserModel userModel;
  final PageController parentScrollController;

  @override
  _AlbumWidgetState createState() => _AlbumWidgetState();
}

class _AlbumWidgetState extends State<AlbumWidget> {
  ScrollController controller;
  TextEditingController commentController;
  int position;
  AudioPlayer audioPlayer;
  bool currentlyPaused;
  @override
  void initState() {
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER, playerId: widget.review.reviewId);
    controller = ScrollController(keepScrollOffset: false);
    commentController = TextEditingController();
    controller.addListener(overScroll);
    currentlyPaused = false;
    playAudio();
    super.initState();
  }

  @override
  void dispose() {
    stopAudio();
    controller.dispose();
    super.dispose();
  }

  void overScroll() {
    if (controller.offset >= controller.position.maxScrollExtent + 80 &&
        controller.offset <= controller.position.maxScrollExtent + 84) {
      widget.parentScrollController.nextPage(duration: kTabScrollDuration, curve: Curves.easeInOutCubic);
    }
    if (controller.offset + 80 <= controller.position.minScrollExtent &&
        controller.offset + 84 >= controller.position.minScrollExtent) {
      widget.parentScrollController.previousPage(duration: kTabScrollDuration, curve: Curves.easeInOutCubic);
    }
  }

  Future<int> stopAudio() async {
    final int result = await audioPlayer.stop();
    audioPlayer.dispose();
    return result;
  }

  Future<int> playAudio() async {
    int result;
    await Future.delayed(const Duration(milliseconds: 700));
    try {
      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      result = await audioPlayer.play(widget.review.previewUrl, isLocal: false);
      audioPlayer.onAudioPositionChanged.listen((Duration time) => setState(() {
            position = time.inSeconds;
          }));
    } catch (e) {
      print('No preview Available');
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if(!currentlyPaused){
                audioPlayer.pause();
                currentlyPaused = true;
              }
              else{
                audioPlayer.resume();
                currentlyPaused = false;
              }
            },
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.review.albumImageUrl ?? placeholderProfileUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  primary: false,
                  physics: const BouncingScrollPhysics(),
                  controller: controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.width * 0.65,
                              width: MediaQuery.of(context).size.width * 0.65,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(widget.review.albumImageUrl ?? placeholderProfileUrl),
                                    fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(widget.review.albumName,
                                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                  '${widget.review.tracks.length > 1 ? 'Album' : 'Song'} by '
                                  '${widget.review.artistName} • ${widget.review.albumYear}',
                                  style: const TextStyle(fontSize: 14, color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: widget.review.featuredTracks.isEmpty ? 24 : 19),
                      if (widget.review.featuredTracks.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'FEATURED TRACKS',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 12.0, color: Color.fromRGBO(255, 255, 255, .5)),
                            ),
                          ),
                        ),
                      if (widget.review.featuredTracks.isNotEmpty) const SizedBox(height: 11),
                      if (widget.review.featuredTracks.isNotEmpty) FeaturedTracks(widget: widget),
                      if (widget.review.featuredTracks.isNotEmpty) const SizedBox(height: 16),
                      Buttons(albumWidget: widget),
                      const SizedBox(height: 18),
                      Comments(albumWidget: widget, commentController: commentController),
                      const SizedBox(height: 0),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ]
            )
          )
        ],
      ),
    );
  }
}

class Buttons extends StatefulWidget {
  const Buttons({
    Key key,
    @required this.albumWidget,
  }) : super(key: key);

  final AlbumWidget albumWidget;

  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  void initState() {
    reviewLiked =
        widget.albumWidget.review.likes.map((Like like) => like.userId).toList().contains(widget.albumWidget.userModel.id);
    super.initState();
  }

  bool reviewLiked;

  void createLike() {
    final Like like = Like(<dynamic, dynamic>{
      'id': widget.albumWidget.userModel.id,
      'name': widget.albumWidget.userModel.name,
      'spotifyImageUrl': widget.albumWidget.userModel.imageUrl,
      'createdAt': TimeOfDay.now().toString(),
      'ReviewLikes': <dynamic, dynamic>{'reviewId': int.parse(widget.albumWidget.review.reviewId)},
    });
    widget.albumWidget.review.likes.add(like);
  }

  void removeLike() {
    widget.albumWidget.review.likes.removeWhere((Like like) => like.userId == widget.albumWidget.userModel.id);
  }

  Future<bool> toggleLike() async {
    print('XXX $reviewLiked');
    if (reviewLiked == false) {
      setState(() {
        createLike();
        reviewLiked = !reviewLiked;
      });
      await widget.albumWidget.review.addLike(widget.albumWidget.review.reviewId);
    } else {
      setState(() {
        removeLike();
        reviewLiked = !reviewLiked;
      });
      await widget.albumWidget.review.delLike(widget.albumWidget.review.reviewId);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              await showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) => PlayModal(review: widget.albumWidget.review));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4), borderRadius: const BorderRadius.all(Radius.circular(4.0))),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 10.0),
                child: Text(
                  '▶ Play',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () async {
              toggleLike();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: reviewLiked ? Colors.white : Colors.white.withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(4.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 10.0),
                child: Text(
                  '👏 Clap',
                  style: TextStyle(color: reviewLiked ? Colors.black : Colors.white, fontSize: 12.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          LikedBubbles(review: widget.albumWidget.review),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Share.share('Check out my review ${widget.albumWidget.review.link}');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.reply, textDirection: TextDirection.rtl, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comments extends StatefulWidget {
  const Comments({
    Key key,
    @required this.albumWidget,
    @required this.commentController,
  }) : super(key: key);

  final AlbumWidget albumWidget;
  final TextEditingController commentController;

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  Future<bool> createComment() async {
    if (widget.commentController.text.isNotEmpty) {
      // The review that the comment is added to
      final Review commentedReview = widget.albumWidget.review;
      final String body = widget.commentController.text;
      widget.commentController.clear();
      final CommentModel commentModel =
          CommentModel(idToken: widget.albumWidget.userModel.idToken, commentData: <String, dynamic>{
        'id': 0,
        'body': body,
        'userId': widget.albumWidget.userModel.id,
        'reviewId': int.parse(commentedReview.reviewId),
        'user': <String, dynamic>{
          'name': widget.albumWidget.userModel.name,
          'spotifyImageUrl': widget.albumWidget.userModel.imageUrl,
          'createdAt': TimeOfDay.now().toString(),
        },
      });
      setState(() {
        commentedReview.comments.add(commentModel);
      });
      commentModel.createComment(commentedReview.reviewId, body);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 12.0),
      child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.albumWidget.review.comments.length)
              return Row(
                children: <Widget>[
                  CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.albumWidget.userModel.imageUrl ?? placeholderProfileUrl,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.commentController,
                      decoration: InputDecoration(
                          hintText: 'Add a commment',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(0)),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (String value) async {
                        if (widget.commentController.text.isNotEmpty) {
                          setState(() {
                            createComment();
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            final CommentModel commentModel = widget.albumWidget.review.comments[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(commentModel.imageUrl ?? placeholderProfileUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: commentModel.userName + '  ',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        children: <InlineSpan>[
                          TextSpan(
                            text: commentModel.body,
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ]),
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (_, int index) => const SizedBox(height: 8),
          itemCount: widget.albumWidget.review.comments.length + 1),
    );
  }
}

class FeaturedTracks extends StatelessWidget {
  const FeaturedTracks({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final AlbumWidget widget;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 15.0, right: 12),
        itemBuilder: (_, int index) {
          return Text(
            widget.review.featuredTracks[index].name,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          );
        },
        separatorBuilder: (_, int index) => const SizedBox(height: 12),
        itemCount: widget.review.featuredTracks.length);
  }
}

class LikedBubbles extends StatelessWidget {
  const LikedBubbles({
    Key key,
    @required this.review,
  }) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    final List<Like> likes = review.likes;
    if (likes.isEmpty) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) => LikedModal(review: review));
      },
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(width: 28),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    likes.length >= 3 ? CachedNetworkImageProvider(likes[2].imageUrl ?? placeholderProfileUrl) : null,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const SizedBox(width: 14),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    likes.isNotEmpty ? CachedNetworkImageProvider(likes[0].imageUrl ?? placeholderProfileUrl) : null,
              ),
            ],
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.transparent,
            backgroundImage:
                likes.length >= 2 ? CachedNetworkImageProvider(likes[1].imageUrl ?? placeholderProfileUrl) : null,
          ),
        ],
      ),
    );
  }
}
