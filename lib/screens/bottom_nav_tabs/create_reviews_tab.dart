import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/common/app_flow.dart';
import 'package:tunestack_flutter/integrations/spotify_connector.dart';
import 'package:tunestack_flutter/screens/review_create_screen.dart';

class CreateReviewsTab extends StatefulWidget {
  @override
  _CreateReviewsTabState createState() => _CreateReviewsTabState();
}

class _CreateReviewsTabState extends State<CreateReviewsTab> {
  Future<void> search(SpotifyConnector spotify, String searchStr) async {
    // spotify.search will update spotify object's album and artist list
    await spotify.search(searchStr);

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateReviewsTab.build()');

    final SpotifyConnector spotify = Provider.of<SpotifyConnector>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reviews', style: TextStyle(color: Colors.black))
      ),
      body: Column(
        children: <Widget>[
          RawKeyboardListener(
            focusNode: FocusNode(),
            child: TextFormField(
              onFieldSubmitted: (String searchStr) {
                search(spotify, searchStr);
              },
              decoration: const InputDecoration(
                hintText: 'Search',
              )
            )
          ),
          const SizedBox(
            height: 24,
          ),
          // TODO(Chase): - Create a generic vertical list widget to simplify the codes
          if (spotify.albumListLen() > 0) const Text('Albums'),
          if (spotify.albumListLen() > 0) Flexible(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: spotify.albumListLen(),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    AppFlow.pushPage(context, ReviewCreateScreen(index: index), <dynamic>[spotify], true);
                  },
                  child: ListTile(
                    leading: Image.network(spotify.albumImageUrl(index)),
                    title: Text(spotify.albumName(index)),
                    subtitle: Text(spotify.albumArtistName(index))
                  )
                );
              }
            )
          ),
          // TODO(Chase): - Create a generic vertical list widget to simplify the codes
          if (spotify.artistsListLen() > 0) const Text('Artists'),
          if (spotify.artistsListLen() > 0) Flexible(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: spotify.artistsListLen(),
              itemBuilder: (BuildContext context, int index) {
                final String artistsImageUrl = spotify.artistsImageUrl(index);
                return ListTile(
                  leading: CircleAvatar(
                    // Some artists don't have images (artistsImageUrl is null). Passing
                    // null into NetworkImage triggers exception
                    backgroundImage: (artistsImageUrl == null) ?
                      null : NetworkImage(artistsImageUrl)
                  ),
                  title: Text(spotify.artistName(index))
                );
              }
            )
          )
        ]
      )
    );
  }
}