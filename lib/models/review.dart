import 'package:tunestack_flutter/common/base_model.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/models/comment.dart';
import 'package:tunestack_flutter/models/like.dart';
import 'package:tunestack_flutter/models/tag.dart';
import 'package:tunestack_flutter/models/track.dart';
import 'package:tunestack_flutter/models/user.dart';

/// Provider package only supports passing one object per data type - We can't pass two
/// ReviewModel objects because both are ReviewModel type. Define this new data type
/// so that we can pass multiple ReviewModel objects into home_tab.
class HomeTabReviews {
  HomeTabReviews(this.followingReviews, this.recommendedReviews);

  ReviewModel followingReviews;
  ReviewModel recommendedReviews;
}

/// Comment data retrieved from backend
class ReviewModel extends BaseModel {
  ReviewModel(String idToken) : super('review', idToken: idToken);

  /// Internal, private state of the reviews
  final List<dynamic> _reviews = <dynamic>[];

  /// Return true to indicate the async operation is complete
  Future<bool> loadAll() async {
    final dynamic responseJson = await get();
    _reviews.addAll(responseJson['items'] as Iterable<dynamic>);

    return true;
  }

  Future<bool> loadMyReviews(String userId) async {
    final dynamic responseJson = await get(parameters: 'user=$userId');
    _reviews.addAll(responseJson['items'] as Iterable<dynamic>);
    return true;
  }

  Future<bool> loadFollowing(String userId) async {
    final dynamic responseJson = await get(parameters: 'followedBy=$userId');
    _reviews.addAll(responseJson['items'] as Iterable<dynamic>);
    return true;
  }

  /// Get recommendations
  Future<bool> loadRecs() async {
    // Recommendations are returned as the 'review' format. Storing recommendations in the ReviewModel
    // allows us to use ReviewModel's member functions. We need to use getFullPath() because the
    // API endpoint is not under /review.
    final dynamic responseJson = await getCustomEndpointPath('taste/recommendations');
    _reviews.addAll(responseJson as Iterable<dynamic>);

    return true;
  }

  Future<bool> addLike(String reviewId) async {
    final dynamic responseJson = await post(subPath: '$reviewId/like');
    print(responseJson);
    return true;
  }

  Future<bool> delLike(String reviewId) async {
    final dynamic responseJson = await delete(subPath: '$reviewId/like');
    print(responseJson);
    return true;
  }

  int listLen() {
    return _reviews.length;
  }

  UserModel getUser(int index) {
    return UserModel(userData: _reviews[index]['user'] as Map<String, dynamic>);
  }

  String reviewId(int index) {
    return '${_reviews[index]['id']}';
  }

  String reviewBody(int index) {
    return _reviews[index]['body'] as String ?? '';
  }

  String albumType(int index) {
    return _reviews[index]['type'] as String ?? '';
  }

  String albumImageUrl(int index) {
    return _reviews[index]['album']['spotifyImageUrl'] as String ?? '';
  }

  String albumName(int index) {
    return _reviews[index]['album']['name'] as String ?? '';
  }

  String albumYear(int index) {
    final String timestamp = _reviews[index]['album']['releaseDate'] as String ?? '';
    return timestamp.substring(0, 4);
  }

  String artistName(int index) {
    return _reviews[index]['album']['artist']['name'] as String ?? '';
  }

  String userName(int index) {
    return _reviews[index]['user']['name'] as String ?? '';
  }

  String userImageUrl(int index) {
    return _reviews[index]['user']['spotifyImageUrl'] as String ?? placeholderProfileUrl;
  }

  bool reccomended(int index) {
    return _reviews[index]['recommend'] as bool;
  }

  bool featured(int index) {
    return _reviews[index]['featured'] as bool;
  }

  String time(int index) {
    final String timeString = _reviews[index]['createdAt'] as String;
    if (timeString != null && timeString != '') {
      final DateTime time = DateTime.parse(timeString);
      final int difference = DateTime.now().difference(time).inMinutes;
      if (difference < 60) {
        return '${difference}m';
      }
      if (difference < 1440) {
        return '${difference ~/ 60}h';
      }
      return '${difference ~/ 1440}d';
    }
    return '';
  }

  List<Track> featuredTracks(int index) {
    final List<Track> toReturn = <Track>[];
    final List<dynamic> tracks = _reviews[index]['featuredTracks'] as List<dynamic> ?? <Track>[];
    for (final dynamic track in tracks) {
      final Map<dynamic, dynamic> map = track as Map<dynamic, dynamic>;
      toReturn.add(Track(map));
    }
    return toReturn ?? <Track>[];
  }

  List<Track> tracks(int index) {
    final List<Track> toReturn = <Track>[];
    final List<dynamic> tracks = _reviews[index]['album']['tracks'] as List<dynamic> ?? <Track>[];
    for (final dynamic track in tracks) {
      final Map<dynamic, dynamic> map = track as Map<dynamic, dynamic>;
      toReturn.add(Track(map));
    }
    return toReturn ?? <Track>[];
  }

  String previewUrl(int index) {
    final List<Track> featTracks = featuredTracks(index);
    // ignore: always_put_control_body_on_new_line
    if (featTracks.isNotEmpty) return featTracks[0].previewUrl;

    final List<Track> allTracks = tracks(index);
    // ignore: always_put_control_body_on_new_line
    if (allTracks[0].previewUrl != null) return allTracks[0].previewUrl;

    // TODO(mlanders): Call API for preview URl
    return '';
  }

  List<Tag> tags(int index) {
    final List<Tag> toReturn = <Tag>[];
    final List<dynamic> tags = _reviews[index]['tags'] as List<dynamic>;
    for (final dynamic tag in tags) {
      final Map<dynamic, dynamic> map = tag as Map<dynamic, dynamic>;
      toReturn.add(Tag(map));
    }
    return toReturn ?? <Tag>[];
  }

  List<Like> likedBy(int index) {
    final List<Like> toReturn = <Like>[];
    final List<dynamic> likes = _reviews[index]['likedBy'] as List<dynamic>;
    for (final dynamic like in likes) {
      final Map<dynamic, dynamic> map = like as Map<dynamic, dynamic>;
      toReturn.add(Like(map));
    }
    return toReturn ?? <Like>[];
  }

  List<CommentModel> comments(int index) {
    final List<CommentModel> toReturn = <CommentModel>[];
    final List<dynamic> comments = _reviews[index]['comments'] as List<dynamic>;
    for (final dynamic comment in comments) {
      toReturn.add(CommentModel(commentData: comment as Map<String, dynamic>));
    }
    return toReturn ?? <CommentModel>[];
  }

  void printOne(int index) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(_reviews[index].toString()).forEach((RegExpMatch match) => print(match.group(0)));
  }
}

/// One review entry of ReviewModel's review list
class Review {
  Review(this.model, this.index) {
    user = model.getUser(index);
    reviewId = model.reviewId(index);
    userName = model.userName(index);
    userImageUrl = model.userImageUrl(index);
    artistName = model.artistName(index);
    albumImageUrl = model.albumImageUrl(index);
    albumName = model.albumName(index);
    albumYear = model.albumYear(index);
    body = model.reviewBody(index);
    time = model.time(index);
    type = model.albumType(index);
    reccomend = model.reccomended(index);
    featured = model.featured(index);
    featuredTracks = model.featuredTracks(index);
    tracks = model.tracks(index);
    previewUrl = model.previewUrl(index);
    tags = model.tags(index);
    comments = model.comments(index);
    likes = model.likedBy(index);
  }
  ReviewModel model;
  int index;
  UserModel user;
  String reviewId;
  String userName;
  String userImageUrl;
  String artistName;
  String albumImageUrl;
  String albumName;
  String albumYear;
  String type;
  String body;
  String time;
  bool reccomend;
  bool featured;
  List<Track> featuredTracks;
  List<Track> tracks;
  String previewUrl;
  List<Tag> tags;
  List<CommentModel> comments;
  List<Like> likes;

  String get link => 'https://share.tunestack.fm/?reviewId=' + reviewId;

  Future<bool> addLike(String userId) async {
    return await model.addLike(userId);
  }

  Future<bool> delLike(String userId) async {
    return await model.delLike(userId);
  }
}
