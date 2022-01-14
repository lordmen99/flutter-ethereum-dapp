import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_eth_wallet/blocs/global_action_cubit/global_action_cubit.dart';
import 'package:flutter_eth_wallet/blocs/wallet_bloc/wallet_bloc.dart';
import 'package:flutter_eth_wallet/modules/event_manager/event_router_observer.dart';
import 'package:flutter_eth_wallet/pages/wallet_route_delegate.dart';
import 'package:flutter_eth_wallet/repository/wallet_repository.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();
final EventRouterObserver<PageRoute> eventRouterObserver = EventRouterObserver();
const WalletRouteInformationParser walletRouteInfoParser = WalletRouteInformationParser();
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => WalletRepository(),
          lazy: false,
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WalletBloc(),
            lazy: false,
          )
        ],
        child: Builder(
          builder: (context) => _buildMaterialApp(context),
        ),
      ),
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: const CupertinoScrollBehavior(),
      builder: (context, child) {
        String themeModeName =
            Theme.of(context).brightness == Brightness.dark ? "dark" : "light";

        return BlocListener<GlobalActionCubit, GlobalActionState>(
          listener: (_, state) => handleActionState(state),
          child: KeyedSubtree(key: Key(themeModeName), child: child!),
        );
      },
      color: Theme.of(context).primaryColor,
      routerDelegate: WalletRouteDelegate.instance(),
      routeInformationParser: walletRouteInfoParser,
    );
  }
}

void handleActionState(GlobalActionState state) async {}


