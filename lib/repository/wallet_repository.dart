
import 'package:flutter_eth_wallet/modules/sp_utils.dart';

class WalletRepository {
  static final WalletRepository _instance = WalletRepository._internal();
  static const _SP_TOKEN_KEY = 'sp_token';

  String? get token => SpUtils.sp.getString(_SP_TOKEN_KEY);
  WalletRepository._internal();
  factory WalletRepository() {
    return _instance;
  }
}
