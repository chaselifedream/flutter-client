class Like {
  Like(Map<dynamic, dynamic> map) {
    userId = map['id'] as String;
    reviewId = map['ReviewLikes']['reviewId'] as int;
    userName = map['name'] as String;
    imageUrl = map['spotifyImageUrl'] as String;
    createdAt = map['createdAt'] as String;
  }

  String userId;
  int reviewId;
  String userName;
  String imageUrl;
  String createdAt;
}
