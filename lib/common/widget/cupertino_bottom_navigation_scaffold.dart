import 'package:tunestack_flutter/common/widget/bottom_navigation_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CupertinoBottomNavigationScaffold extends StatelessWidget {
  const CupertinoBottomNavigationScaffold({
    @required this.navigationBarItems,
    @required this.onItemSelected,
    @required this.selectedIndex,
    Key key,
  })  : assert(navigationBarItems != null),
        assert(onItemSelected != null),
        assert(selectedIndex != null),
        super(key: key);

  /// List of the tabs to be displayed with their respective navigator's keys.
  final List<BottomNavigationTab> navigationBarItems;

  /// Called when a tab selection occurs.
  final ValueChanged<int> onItemSelected;

  final int selectedIndex;

  @override
  Widget build(BuildContext context) => CupertinoTabScaffold(
        // As we're managing the selected index outside, there's no need
        // to make this Widget stateful. We just need pass the selectedIndex to
        // the controller every time the widget is rebuilt.
        controller: CupertinoTabController(initialIndex: selectedIndex),
        tabBar: CupertinoTabBar(
          items: navigationBarItems
              .map(
                (BottomNavigationTab item) => item.bottomNavigationBarItem,
              )
              .toList(),
          onTap: onItemSelected,
        ),
        tabBuilder: (BuildContext context, int index) {
          final BottomNavigationTab barItem = navigationBarItems[index];
          return CupertinoTabView(
            onGenerateRoute: (RouteSettings settings) => CupertinoPageRoute<dynamic>(
              settings: settings,
              builder: barItem.initialPageBuilder,
            ),
          );
        },
      );
}
