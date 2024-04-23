import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/common/app_flow.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/screens/review_view_screen.dart';

enum ItemType { Review }

/// Generic horizontal list widget, currently only support ReviewModel list.
/// In future, we want to generalize the type for other data models, such as CommentModel.
class HorizontalList extends StatefulWidget {
  const HorizontalList({Key key, this.itemType}) : super(key: key);

  final ItemType itemType;

  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  @override
  Widget build(BuildContext context) {
    final ReviewModel reviewModel =
        Provider.of<ReviewModel>(context, listen: false);

    return FutureBuilder<bool>(
        future: reviewModel.loadAll(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return Container(
              height: MediaQuery.of(context).size.height / 3,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: reviewModel.listLen(),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap: () {
                        AppFlow.pushPage(
                            context,
                            ReviewViewScreen(index: index, model: reviewModel),
                            <dynamic>[reviewModel],
                            true);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Card(
                          //color: Colors.blue,
                          child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      reviewModel.albumImageUrl(index)),
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              child: Text(reviewModel.albumName(index))),
                        ),
                      ));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 12.0);
                },
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
