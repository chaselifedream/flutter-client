class Tag {
  
  Tag(Map<dynamic, dynamic> map){
    id = map['id'] as int;
    name = map['name'] as String;
    description = map['albumId'] as String;
    imageUrl = map['trackNumber'] as String;
    playlistUrl = map['spotifyPreviewUrl'] as String;
    featured = map['featured'] as bool;
  }

  int id;
  String name;
  String description;
  String imageUrl;
  String playlistUrl;
  bool featured;
}