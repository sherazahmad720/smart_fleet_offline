import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  RxBool isInternetAvailable = true.obs;
  // checkInternetStatus() async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       print('connected');
  //       return true;
  //     }
  //   } on SocketException catch (_) {
  //     print('not connected');
  //     return false;
  //   }
  // }

/* ------------------ check data connection is working fine ----------------- */

  checkData() async {
    var _value = await DataConnectionChecker().hasConnection;
    return _value;
  }

/* ------- check mobile data or wifi on or not if on then workin fine ------- */

  checkInternet() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      bool data = await checkData();
      if (data) {
        isInternetAvailable.value = true;
        return true;
      } else {
        isInternetAvailable.value = false;
        return false;
      }
    } else {
      isInternetAvailable.value = false;
      return false;
    }
  }

/* ---------------------- realtime check for connection --------------------- */

  realtimeConnectionCheck() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkInternet();
    });
  }
}
