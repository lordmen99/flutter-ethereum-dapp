
import 'dart:developer';

import 'package:flutter/material.dart';

class EventRouterObserver<R extends Route<dynamic>> extends RouteObserver {
  List<RouteSettings> routeNames = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    routeNames.add(route.settings);
    log("EventRouteObserver: didPush: ${route.settings.name}, previousRoute: ${previousRoute}");
    switch (route.settings.name) {
      default:
        break;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final settings = routeNames.removeLast();
    log("EventRouteObserver: didPop: ${route.settings.name}, last: ${settings.name}, previousRoute: ${previousRoute}");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log("EventRouteObserver: didRemove: ${route.settings.name}, previousRoute: ${previousRoute}");

    int index = routeNames.lastIndexWhere((element) => element.name == route.settings.name);
    if (index >= 0) {
      final settings = routeNames.removeAt(index);
      log("EventRouteObserver: didRemove routeNames: ${settings.name}");
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    log("EventRouteObserver: didReplace newRoute: ${newRoute}, oldRoute: ${oldRoute}");
    int index = routeNames.lastIndexWhere((element) => element.name == oldRoute?.settings.name);
    if (index >= 0 && newRoute != null) {
      routeNames[index] = newRoute.settings;
    }
  }
}