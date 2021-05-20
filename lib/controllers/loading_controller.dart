import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  showLoading() {
    EasyLoading.show(
      status: 'loading...',
    );
  }

  stopLoading() {
    EasyLoading.dismiss();
  }

  loadingSuccess() {
    EasyLoading.showSuccess('Email sent');
  }
}
