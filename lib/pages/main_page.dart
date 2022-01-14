
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_eth_wallet/blocs/global_action_cubit/global_action_cubit.dart';
import 'package:flutter_eth_wallet/blocs/wallet_bloc/wallet_bloc.dart';
import 'package:flutter_eth_wallet/pages/home_page.dart';
import 'package:flutter_eth_wallet/pages/mine_home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key, }) : super(key: key);
  static const sName = "/";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WalletBloc(),
        ),
        BlocProvider(create: (_) => GlobalActionCubit())
      ],
      child: MainScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {

  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() =>
      _MainScreenState();
}

enum HomePages { Home, Mine }

class _MainScreenState
    extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  HomePages page = HomePages.Home;
  Map<HomePages, IconData> barIconsSelected = <HomePages, IconData>{
    HomePages.Home: Icons.home_filled,
    HomePages.Mine: Icons.menu_open
  };
  Map<HomePages, IconData> barIcons = {
    HomePages.Home: Icons.home,
    HomePages.Mine: Icons.menu
  };
  Map<HomePages, Widget> pages = {
    HomePages.Home: HomePage(),
    HomePages.Mine: MineHomePage()
  };
  final String dragData = "dragData";

  late AnimationController _controller;

  late Animation<double> _radiusAnimation;
  late Animation<double> _blurAnimation;
  double barHeight = 60;
  final double _radius = 100;
  String? _selectText;
  bool _isSelectedItem = false;

  final StreamController<bool> _streamController =
  StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _radiusAnimation = Tween<double>(begin: 0, end: _radius)
        .chain(CurveTween(curve: Curves.fastOutSlowIn))
        .animate(_controller);
    _blurAnimation = Tween<double>(begin: 0, end: 5)
        .chain(CurveTween(curve: Curves.fastOutSlowIn))
        .animate(_controller);


  }

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    super.dispose();
  }

  void onTappedItem(HomePages page) {
    if (this.page == page) {
      return;
    }
    setState(() {
      this.page = page;
    });
  }

  bool isStartSelect = false;

  void startSelect() {
    setState(() {
      if (isStartSelect) {
        _selectText = null;
        _controller.reverse();
      } else {
        _controller.forward();
      }
      isStartSelect = !isStartSelect;
    });
  }

  void finishSelect() {
    _streamController.add(false);
    setState(() {
      _controller.reverse();
      isStartSelect = false;
      _selectText = null;
      _isSelectedItem = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Scaffold(
              extendBody: true,
              resizeToAvoidBottomInset: false,
              body: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  pages[this.page]!,

                  Visibility(
                      visible:Theme.of(context).brightness == Brightness.dark,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: selectedItemEndPoint(context) * 1.3,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                  stops: [0, 1])),
                        ),
                      )),

                  Positioned(
                    bottom: 25 + MediaQuery.of(context).padding.bottom,
                    child: buildBottomMenuItems(context),
                  ),

                  AnimatedBuilder(
                    builder: (context, child) {
                      return Positioned.fill(
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Visibility(
                                  visible: _blurAnimation.value > 0.01,
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 2.5,
                                      sigmaY: 2.5,
                                    ),
                                    child: GestureDetector(
                                        onTap: finishSelect, child: child),
                                  ),
                                ),

                                Positioned(
                                  bottom:
                                  selectedItemEndPoint(context) + _radius + 100,
                                  child: Visibility(
                                    visible: _blurAnimation.value > 0.01 &&
                                        _selectText != null &&
                                        _isSelectedItem,
                                    child: Text(_selectText ?? '',),
                                  ),
                                ),
                              ]));
                    },
                    animation: _blurAnimation,
                    child: buildMenuItems(),
                  ),
                ],
              ),

              floatingActionButton: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                reverseDuration: const Duration(milliseconds: 100),
                transitionBuilder: (child, animation) {
                  final anim =
                  Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
                      .animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: anim,
                      child: child,
                    ),
                  );
                },
                child: Container(height: 0),
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

              bottomNavigationBar: Builder(builder: (context) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  reverseDuration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    final anim =
                    Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
                        .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: anim,
                        child: child,
                      ),
                    );
                  },
                  child: BottomAppBar(
                    notchMargin: 16.0,
                    elevation:
                    Theme.of(context).brightness == Brightness.dark
                        ? null
                        : 8,
                    child: Container(
                      height: barHeight,
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        // children: barMembers(),
                        children: [
                          barItem(0),
                          const SizedBox(
                            width: 100,
                          ),
                          barItem(1),
                        ],
                      ),
                    ),
                  )
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget buildBottomMenuItems(BuildContext context) {
    return Builder(builder: (context) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Container(key: const Key("empty"))

      );
    });
  }

  double selectedItemEndPoint(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    if (barHeight >= bottom) {
      return barHeight;
    } else {
      return bottom;
    }
  }

  Widget buildMenuItems() {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              buildImportFileButton(constraint),
            ],
          );
        },
      ),
    );
  }

  Widget buildRecorderButton(BoxConstraints constraint) {
    return AnimatedBuilder(
      animation: _radiusAnimation,
      builder: (context, child) {
        return Container();
      }
      );
  }


  Widget buildImportFileButton(BoxConstraints constraint) {
    return AnimatedBuilder(
      animation: _radiusAnimation,
      builder: (context, child) {
        return  Container();
      },
    );
  }


  Widget MenuButton({
    required String svg,
    required String text,
    bool isDanger = false,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 80.0,
        ),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 2),
              Text(
                text,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> barMembers() {
    return List.generate(barIcons.length, (index) => barItem(index));
  }

  Widget barItem(int index) {
    final page = HomePages.values[index];
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isStartSelect) {
            return;
          }
          onTappedItem(page);
        },
        child: Container(
          height: 58.0,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: [
                Builder(builder: (context) {
                  final bool visible = index == 1 ;
                  return Visibility(
                    visible: visible,
                    child: Positioned(
                      top: 6,
                      right: -3,
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  );
                }),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 10.0)),
                    buildBarIcon(page),
                    Padding(padding: const EdgeInsets.only(top: 2.0)),
                    Builder(builder: (context) {
                      final itemTitles = [
                      ];
                      return Text(
                        itemTitles[index],
                      );
                    })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBarIcon(HomePages page) {
    return const Icon(Icons.home);
  }

  Color? itemColor(HomePages page) {
    return this.page == page
        ? Colors.white
        : Colors.blue;
  }
}
