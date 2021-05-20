import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smart_fleet/constants/constants.dart';

customAlertDialog(context, {String userType, deleteAction, editAction}) {
  return Alert(
    context: context,
    type: AlertType.warning,
    title: "Action",
    desc: "Select an Action",
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
      if (userType != 'User')
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: deleteAction,
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        ),
      // if (userType == 'User')
      DialogButton(
        child: Text(
          "Edit",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: editAction,
        gradient: LinearGradient(colors: [
          Color.fromRGBO(116, 116, 191, 1.0),
          Color.fromRGBO(52, 138, 199, 1.0)
        ]),
      )
    ],
  ).show();
}
