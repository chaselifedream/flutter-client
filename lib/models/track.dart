class Track {

  Track(Map<dynamic, dynamic> map){
    id = map['id'] as int;
    albumid = map['albumId'] as int;
    trackNumber = map['trackNumber'] as int;
    name = map['name'] as String;
    previewUrl = map['spotifyPreviewUrl'] as String;
  }

  int id;
  int albumid;
  int trackNumber;
  String name;
  String previewUrl;
}