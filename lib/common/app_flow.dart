import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:tunestack_flutter/integrations/spotify_connector.dart';
import 'package:tunestack_flutter/models/review.dart';

/// Holds information about our app's flows.
class AppFlow {
  const AppFlow(
      {@required this.title,
      @required this.iconData,
      @required this.key,
      @required this.navigatorKey,
      @required this.initialPageBuilder,
      this.parameter})
      : assert(title != null),
        assert(iconData != null),
        assert(key != null),
        assert(navigatorKey != null),
        assert(initialPageBuilder != null);

  final String title;
  final IconData iconData;
  final String key; // Used in automation to trigger tab clicking
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) initialPageBuilder;
  final dynamic parameter;

  /// Push a new screen page to the navigation tree.
  ///
  /// User will navigate to [page]. [providerData] is the list of data we want
  /// [page] to access through Provider.
  static void pushPage(BuildContext context, Widget page,
      List<dynamic> providerData, bool isHorizontalNavigation) {
    final List<SingleChildWidget> providers =
        providerData.map((dynamic item) => _getProvider(item)).toList();

    final MultiProvider Function(BuildContext) builder =
        (BuildContext context) =>
            MultiProvider(providers: providers, child: page);

    // If it's not horizontal navigation, we should use the rootNavigator.
    Navigator.of(context, rootNavigator: !isHorizontalNavigation).push<dynamic>(
      _buildAdaptivePageRoute<dynamic>(
        builder: builder,
        fullscreenDialog: !isHorizontalNavigation,
      ),
    );
  }

  // Flutter will use the fullscreenDialog property to change the animation
  // and the app bar's left icon to an X instead of an arrow.
  static PageRoute<T> _buildAdaptivePageRoute<T>({
    @required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) =>
      Platform.isAndroid
          ? MaterialPageRoute<T>(
              builder: builder,
              fullscreenDialog: fullscreenDialog,
            )
          : CupertinoPageRoute<T>(
              builder: builder,
              fullscreenDialog: fullscreenDialog,
            );

  /// Create Provider data based on the data type.
  ///
  /// Dart doesn't support parameter type assignment programmatically so need this
  /// function.
  static SingleChildWidget _getProvider(dynamic item) {
    if (item is ReviewModel) {
      return Provider<ReviewModel>(create: (BuildContext context) => item);
    }
    if (item is SpotifyConnector) {
      return Provider<SpotifyConnector>(create: (BuildContext context) => item);
    }

    throw 'Type ${item.runtimeType} is not supported';
  }
}
