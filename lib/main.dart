import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_eth_wallet/blocs/bloc_observer.dart';
import 'package:flutter_eth_wallet/modules/sp_utils.dart';
import 'package:flutter_eth_wallet/pages/wallet_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async{
    WidgetsFlutterBinding.ensureInitialized();
    SpUtils.sp = await SharedPreferences.getInstance();
    Bloc.observer = AppBlocObserver();
    runApp(const MyApp());
  } , (obj, stackTrace) {
    try {
      if (!kReleaseMode ) {
      }
    } catch (_) {}
  });
}
