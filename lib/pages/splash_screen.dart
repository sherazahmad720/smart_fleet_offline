import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/connectivity_controller.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/pages/all_users.dart';
import 'package:smart_fleet/pages/home_page.dart';
import 'package:smart_fleet/pages/login_screen.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DbController dbController = Get.put(DbController());
  AuthController authController = Get.put(AuthController());
  ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  @override
  void initState() {
    goToNextPage();
    super.initState();
  }

  goToNextPage() {
    Future.delayed(Duration(seconds: 2), () async {
      dbController.checkUserLoginStatus();

      bool interNet = await connectivityController.checkInternet();
      connectivityController.realtimeConnectionCheck();
      Get.back();
      if (dbController.localEmail == '' || interNet) {
        Get.off(LoginPage());
      } else if (!interNet) {
        authController.userModel.userType = dbController.userType;
        dbController.userType == 'Admin'
            ? Get.off(() => AllUserPage())
            : Get.off(() => HomePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 100,
          child: Column(
            children: [
              customText(
                'Smart Fleet',
                size: 40,
                isBold: true,
              ),
              customText(
                'Welcome...',
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
