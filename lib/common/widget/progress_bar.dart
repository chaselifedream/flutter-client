import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    @required this.total,
    @required this.progress,
    @required this.size,
    Key key,
  }) : super(key: key);

  final int total;
  final int progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: size,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(size / 2))),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: progress,
              child: Container(
                height: size,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(size / 2))),
              ),
            ),
            Expanded(flex: total - progress, child: const SizedBox())
          ],
        ),
      ],
    );
  }
}
