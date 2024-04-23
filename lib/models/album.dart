import 'package:tunestack_flutter/common/base_model.dart';

/// Comment data retrieved from backend
class AlbumModel extends BaseModel {
  AlbumModel(): super('album');

  /// Get album by Spotify uri
  /// At backend an arbitrary integer is used as primary key instead of spotifyUri
  /// so we can list albums that were not on Spotify (e.g. soundcloud collections)
  Future<dynamic> albumBySpotifyUri(final String spotifyUri) async {
    final dynamic responseJson = await get(subPath: 'spotify-album/$spotifyUri');

    return responseJson;
  }

}
