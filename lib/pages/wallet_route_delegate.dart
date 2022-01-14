import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_eth_wallet/modules/commot/context.dart';
import 'package:flutter_eth_wallet/pages/router.dart';
import 'package:flutter_eth_wallet/pages/wallet_app.dart';
import 'package:flutter_eth_wallet/repository/wallet_repository.dart';

import 'guide_page.dart';
import 'main_page.dart';


const WalletRouteInformationParser walletRouteInfoParser = WalletRouteInformationParser();

class WalletRouteDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  static WalletRouteDelegate? _instance;
  WalletRouteDelegate._(this._walletRepository);

  factory WalletRouteDelegate.instance({WalletRepository? walletRepository}) {
    return _instance ??=
        WalletRouteDelegate._(walletRepository ?? WalletRepository());
  }

  final WalletRepository _walletRepository;

  late final _pages = <Page>[
    if(_walletRepository.token == null)
      _buildMaterialPage(GuidePage.sName)
    else
      _buildMaterialPage(MainPage.sName)
  ];

  final StreamController<List<Page>> _pagesController = StreamController.broadcast();
  Stream<List<Page>> get pageStream async* {
    yield _pages;
    yield* _pagesController.stream;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _pagesController.add(_pages);
  }


  @override
  List<Page> get currentConfiguration => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [eventRouterObserver, routeObserver],
      pages: List.of(_pages),
      transitionDelegate: const WalletTransitionDelegate(),
      onPopPage: (route, result) {
        if(_pages.length > 1) {
          _pages.removeLast();
        }
        notifyListeners();
        return route.didPop(result);
      },
    );
  }

  void push(String name, {dynamic arguments}) {
    final Page page;

    page = _buildMaterialPage(name, arguments);
    _pages.add(page);
    notifyListeners();
  }

  Page<dynamic> _buildMaterialPage(String name, [arguments]) {
    final routeSetting = RouteSettings(name: name, arguments: arguments);
    return MaterialPage(
        key: ValueKey(routeSetting.name),
        name: routeSetting.name,
        arguments: routeSetting.arguments,
        child: RouterManager.buildPage(routeSetting)
    );
  }

  void pop<T>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }

  void initToGuidePage() {
    if (_pages.isEmpty || RouterManager.isNoTokenPage(_pages.last.name)) {
      return;
    }
    _pages.clear();
    _pages.add(_buildMaterialPage(GuidePage.sName));
    notifyListeners();
  }

  void loginToHomePage({dynamic arguments}) {
    final String routeName;
    routeName = MainPage.sName;

    _pages.clear();
    _pages.add(_buildMaterialPage(routeName, arguments));
    notifyListeners();
  }

  void backToHomePage() {
    _pages.clear();
    _pages.add(_buildMaterialPage(MainPage.sName));
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalContext.navigatorKey;

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) async {

    return;
  }
}

class WalletRouteInformationParser extends RouteInformationParser<List<RouteSettings>> {

  const WalletRouteInformationParser() : super();

  @override
  Future<List<RouteSettings>> parseRouteInformation(RouteInformation routeInformation) {

    final uri = Uri.parse(routeInformation.location!);

    if (uri.pathSegments.isEmpty) {
      return Future.value([const RouteSettings(name: MainPage.sName)]);
    }

    final routeSettings = uri.pathSegments
        .map((pathSegment) => RouteSettings(
      name: '/$pathSegment',
      arguments: pathSegment == uri.pathSegments.last
          ? uri.queryParameters
          : null,
    ))
        .toList();

    return Future.value(routeSettings);
  }

  @override
  RouteInformation? restoreRouteInformation(List<RouteSettings> configuration) {
    return null;
  }
}

class WalletTransitionDelegate extends TransitionDelegate {

  const WalletTransitionDelegate(): super();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord> locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>> pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];
    void handleExitingRoute(RouteTransitionRecord? location, bool isLast) {
      final RouteTransitionRecord? exitingPageRoute = locationToExitingPageRoute[location];
      if (exitingPageRoute == null) {
        return;
      }
      if (exitingPageRoute.isWaitingForExitingDecision) {
        final bool hasPagelessRoute = pageRouteToPagelessRoutes.containsKey(exitingPageRoute);
        final bool isLastExitingPageRoute = isLast && !locationToExitingPageRoute.containsKey(exitingPageRoute);
        if (isLastExitingPageRoute && !hasPagelessRoute) {
          exitingPageRoute.markForPop(exitingPageRoute.route.currentResult);
        } else {
          exitingPageRoute.markForComplete(exitingPageRoute.route.currentResult);
        }
        if (hasPagelessRoute) {
          final List<RouteTransitionRecord> pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute]!;
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            // It is possible that a pageless route that belongs to an exiting
            // page-based route does not require exiting decision. This can
            // happen if the page list is updated right after a Navigator.pop.
            if (pagelessRoute.isWaitingForExitingDecision) {
              if (isLastExitingPageRoute && pagelessRoute == pagelessRoutes.last) {
                pagelessRoute.markForPop(pagelessRoute.route.currentResult);
              } else {
                pagelessRoute.markForComplete(pagelessRoute.route.currentResult);
              }
            }
          }
        }
      }
      results.add(exitingPageRoute);

      // It is possible there is another exiting route above this exitingPageRoute.
      handleExitingRoute(exitingPageRoute, isLast);
    }

    // Handles exiting route in the beginning of list.
    handleExitingRoute(null, newPageRouteHistory.isEmpty);

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      final bool isLastIteration = newPageRouteHistory.last == pageRoute;
      if (pageRoute.isWaitingForEnteringDecision) {
        if (!locationToExitingPageRoute.containsKey(pageRoute) && isLastIteration) {
          pageRoute.markForPush();
        } else {
          pageRoute.markForAdd();
        }
      }
      results.add(pageRoute);
      handleExitingRoute(pageRoute, isLastIteration);
    }
    return results;
  }
}
