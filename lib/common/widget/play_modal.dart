import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tunestack_flutter/common/theme.dart';
import 'package:tunestack_flutter/common/widget/progress_bar.dart';
import 'package:tunestack_flutter/models/review.dart';

class PlayModal extends StatefulWidget {
  const PlayModal({
    @required this.review,
    Key key,
  }) : super(key: key);

  final Review review;

  @override
  _PlayModalState createState() => _PlayModalState();
}

class _PlayModalState extends State<PlayModal> {
  AudioPlayer audioPlayer;
  int position = 0;
  bool previewAvailable = true;
  @override
  void initState() {
    audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER, playerId: widget.review.reviewId);
    print('URL: ${widget.review.previewUrl}');
    playAudio();

    super.initState();
  }

  Future<int> playAudio() async {
    int result;
    try {
      result = await audioPlayer.play(widget.review.previewUrl, isLocal: false);
      audioPlayer.onAudioPositionChanged.listen((Duration time) => setState(() {
            position = time.inSeconds;
          }));
    } catch (e) {
      print('No preview Available');
      setState(() {
        previewAvailable = false;
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ignore: always_put_control_body_on_new_line
        if (audioPlayer != null) await audioPlayer.stop();
        return true;
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: CachedNetworkImage(imageUrl: widget.review.albumImageUrl ?? placeholderProfileUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 7,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(previewAvailable ? 'PREVIEWING' : 'NO PREVIEW AVAILABLE',
                            style: const TextStyle(fontSize: 12, color: Color.fromRGBO(0, 0, 0, 0.5))),
                        const SizedBox(height: 2),
                        Text(
                          widget.review.albumName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.review.artistName,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        if (previewAvailable) ProgressBar(total: 30, progress: position, size: 8)
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 64,
                        width: 64,
                        decoration:
                            const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(13))),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Spotify',
                        style: TextStyle(fontSize: 12, color: Color.fromRGBO(0, 0, 0, 0.5)),
                      )
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.25), width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(13))),
                        child: const Center(
                            child: Icon(Icons.reply,
                                size: 40, textDirection: TextDirection.rtl, color: Color.fromRGBO(0, 0, 0, 0.25))),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share Link',
                        style: TextStyle(fontSize: 12, color: Color.fromRGBO(0, 0, 0, 0.5)),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
