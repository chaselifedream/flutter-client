import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:tunestack_flutter/models/user.dart';
import 'package:tunestack_flutter/models/review.dart';
import 'package:tunestack_flutter/models/album.dart';
import 'package:tunestack_flutter/common/app_flow.dart';
import 'package:tunestack_flutter/common/widget/adaptive_bottom_navigation_scaffold.dart';
import 'package:tunestack_flutter/common/widget/bottom_navigation_tab.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/home_tab.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/explore_tab.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/create_reviews_tab.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/notification_tab.dart';
import 'package:tunestack_flutter/screens/bottom_nav_tabs/profile_tab.dart';

class BottomNavScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('BottomNavScreen.build()');

    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final List<AppFlow> appFlows = <AppFlow>[
      AppFlow(
          title: 'Home',
          iconData: Icons.home,
          key: 'tab_home',
          navigatorKey: GlobalKey<NavigatorState>(),
          initialPageBuilder: (BuildContext context) => HomeTab()),
      AppFlow(
          title: 'Explore',
          iconData: Icons.language,
          key: 'tab_explore',
          navigatorKey: GlobalKey<NavigatorState>(),
          initialPageBuilder: (BuildContext context) => ExploreTab()),
      AppFlow(
          title: 'Create Reviews',
          iconData: Icons.mode_edit,
          key: 'tab_create_reviews',
          navigatorKey: GlobalKey<NavigatorState>(),
          initialPageBuilder: (BuildContext context) => CreateReviewsTab()),
      AppFlow(
          title: 'Notification',
          iconData: Icons.notifications,
          key: 'tab_notification',
          navigatorKey: GlobalKey<NavigatorState>(),
          initialPageBuilder: (BuildContext context) => NotificationTab()),
      AppFlow(
          title: 'Profile',
          iconData: Icons.person,
          key: 'tab_profile',
          navigatorKey: GlobalKey<NavigatorState>(),
          initialPageBuilder: (BuildContext context) => ProfileTab(bottomNavContext: context, user: null))
    ];
    // Users see this screen only after logged in, so idToken is available
    final ReviewModel reviewModel = ReviewModel(userModel.idToken);
    final AlbumModel albumModel = AlbumModel();

    final List<BottomNavigationTab> navigationBarItems = appFlows
        .map<BottomNavigationTab>((AppFlow flow) => BottomNavigationTab(
            bottomNavigationBarItem: BottomNavigationBarItem(
              // 'key' used in automation to trigger tab clicking
              title: Text(flow.title, key: Key(flow.key)),
              icon: Icon(flow.iconData, color: Colors.blue.shade400),
            ),
            navigatorKey: flow.navigatorKey,
            initialPageBuilder: flow.initialPageBuilder))
        .toList();

    return MultiProvider(providers: <SingleChildWidget>[
      // Provider calls build() only one time
      Provider<ReviewModel>(create: (BuildContext context) => reviewModel),
      Provider<AlbumModel>(create: (BuildContext context) => albumModel)
    ], child: AdaptiveBottomNavigationScaffold(navigationBarItems: navigationBarItems));
  }
}
