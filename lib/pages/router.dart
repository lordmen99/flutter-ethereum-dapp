import 'package:flutter/material.dart';
import 'package:flutter_eth_wallet/pages/guide_page.dart';
import 'package:flutter_eth_wallet/pages/main_page.dart';



class RouterManager {
  RouterManager._();

  static bool isNoTokenPage(String? routeName) {
    switch (routeName) {
      case GuidePage.sName:
        return true;
      default:
        return false;
    }
  }

  static Widget buildPage(RouteSettings settings) {
    Widget? page;
    String? routeName = settings.name;

    switch (routeName) {

      case GuidePage.sName:
        page = const GuidePage();
        break;

      case MainPage.sName:
        page = const MainPage();
        break;

      default:
        page = Scaffold(
          body: Center(
            child: Text("page not found: $routeName"),
          ),
        );
    }
    return page;
  }

  static PageRoute<dynamic> factory(RouteSettings settings) {
    final page = buildPage(settings);
    return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return page;
        });
  }
}
