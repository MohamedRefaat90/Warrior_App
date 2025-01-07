import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static bool? isOnline;

  static init() async {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      print(result);
      if (result.contains(ConnectivityResult.none)) {
        isOnline = false;
      } else {
        isOnline = true;
      }
    });
  }
}
