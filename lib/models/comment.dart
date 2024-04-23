import 'package:tunestack_flutter/common/base_model.dart';

class CommentModel extends BaseModel {
  CommentModel({String idToken, Map<String, dynamic> commentData}):
    _commentData = commentData,
    super('comment', idToken: idToken);

  /// Comment data from our backend database
  final Map<String, dynamic> _commentData;

  String get imageUrl => _commentData['user']['spotifyImageUrl'] as String;
  String get userName => _commentData['user']['name'] as String;
  String get body => _commentData['body'] as String;

  Future<bool> createComment(String reviewId, String body) async {
    final dynamic responseJson = await post(body: <String, dynamic>{'reviewId': int.parse(reviewId), 'body': body});
    print(responseJson);
    return true;
  }

/*
  Comment(Map<dynamic, dynamic> map) {
    id = map['id'] as int;
    body = map['body'] as String;
    userId = map['userId'] as String;
    reviewId = map['reviewId'] as int;
    userName = map['user']['name'] as String;
    imageUrl = map['user']['spotifyImageUrl'] as String;
    createdAt = map['user']['createdAt'] as String;

    int id;
    String body;
    String userId;
    int reviewId;
    String userName;
    String imageUrl;
    String createdAt;
  }
*/
}
