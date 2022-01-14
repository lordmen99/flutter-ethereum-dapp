
import 'package:flutter/cupertino.dart';

class MineHomePage extends StatelessWidget{
  const MineHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final List<Widget> children = [

    ];
    final topOffset = MediaQuery.of(context).padding.top;
    children.insert(
        0,
        SizedBox(
          width: double.infinity,
          height: topOffset,
        ));
    return ListView(
      padding: const EdgeInsets.only(top: 0.0, bottom: 72.0),
      children: children,
    );
  }
}