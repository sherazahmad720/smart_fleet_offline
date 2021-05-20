import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smart_fleet/constants/constants.dart';

logoutDialog(context, {logoutAction}) {
  return Alert(
    context: context,
    type: AlertType.warning,
    title: "Logout",
    desc: "Are you want to logout from this device",
    buttons: [
      DialogButton(
        child: Text(
          "Cancel",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () {
          Get.back();
        },
        gradient: LinearGradient(colors: [
          Color.fromRGBO(116, 116, 191, 1.0),
          Color.fromRGBO(52, 138, 199, 1.0)
        ]),
      ),
      DialogButton(
        child: Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: logoutAction,
        gradient: LinearGradient(colors: [
          Color.fromRGBO(116, 116, 191, 1.0),
          Color.fromRGBO(52, 138, 199, 1.0)
        ]),
      ),
    ],
  ).show();
}
