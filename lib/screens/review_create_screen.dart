import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/integrations/spotify_connector.dart';
import 'package:tunestack_flutter/models/album.dart';
import 'package:tunestack_flutter/models/review.dart';

/// Where a user can post a review on an album
class ReviewCreateScreen extends StatelessWidget {
  ReviewCreateScreen({
    @required this.index,
    Key key,
  })  : assert(index != null),
        super(key: key);

  // index of the selected review
  final int index;
  final TextEditingController reviewTextController = TextEditingController();

  Future<void> postReview(BuildContext context, ReviewModel reviewModel, AlbumModel albumModel, SpotifyConnector spotify) async {
    final dynamic album = await albumModel.albumBySpotifyUri(spotify.albumId(index));
    final Map<String, dynamic> body = <String, dynamic> {
      'albumId': album['id'],
      'body': reviewTextController.text,
      'recommend': 'true',
      'featuredTracks': <dynamic>[],
      'tags': <dynamic>[]
    };

    await reviewModel.post(body: body);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Review.build()');

    final SpotifyConnector spotify = Provider.of<SpotifyConnector>(context, listen: false);
    final ReviewModel reviewModel = Provider.of<ReviewModel>(context, listen: false);
    final AlbumModel albumModel = Provider.of<AlbumModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(spotify.albumName(index))
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: NetworkImage(spotify.albumImageUrl(index, large: true)),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter
            ),
            const SizedBox(height: 8),
            Text('Album: ${spotify.albumName(index)}'),
            const SizedBox(height: 8),
            Text('User: ${spotify.albumArtistName(index)}'),
            TextField(
              controller: reviewTextController,
              decoration: InputDecoration(
                hintText: 'What did you think of ${spotify.albumName(index)}?'
              )
            ),
            const SizedBox(height: 30),
            RaisedButton(
              onPressed: () {
                postReview(context, reviewModel, albumModel, spotify);
              },
              child: const Text('Post')
            )
          ]
        )
      )
    );
  }
}