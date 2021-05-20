import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/models/user_model.dart';

import 'api_controller.dart';
import 'loading_controller.dart';

class AuthController extends GetxController {
  ApiController apiController = Get.put(ApiController());
  LoadingController loadingController = Get.put(LoadingController());
  UserModel userModel = UserModel();
  List<UserModel> allUserList = [];
  RegExp regEmail = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  RegExp regPassword = new RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  String email, password, firstName, lastName, phoneNumber;
  List errorList = [];
  var loginFormKey = GlobalKey<FormState>();
  var signUpFormKey = GlobalKey<FormState>();

  bool isPasswordShow = false, isNewPassShow = false;
  TextEditingController newPasswordController = TextEditingController(),
      confirmPasswordController = TextEditingController();
  UserModel selectedUser;
  String passwordValidator(val) {
    if (!regPassword.hasMatch(val)) {
      return 'password must be at least 8 characters. \n password must have at least one non alphanumeric character.\n password must have at least one digit(0,9)\n password must have at least one uppercase (A-Z).';
    }
    return null;
  }

  RefreshController userRefreshController =
      RefreshController(initialRefresh: false);

  String emailValidator(String val) {
    if (!regEmail.hasMatch(val)) {
      return 'please enter a valid email';
    }
    return null;
  }

  String nameValidator(String val) {
    if (val.length < 2) {
      return 'Field required at least 2 character';
    }
    return null;
  }

  String phoneValidator(String val) {
    if (val == '') {
      return 'Field required ';
    }
    return null;
  }

  login() {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      userModel.email = email;

      userModel.password = password;

      apiController.login(userModel);
    }
  }

  getTrips() {
    apiController.getAllTrips(userModel, selectedUser: selectedUser);
  }

  getAllUser() {
    apiController.getAllUser(
      userModel,
    );
  }

  signUp() {
    if (signUpFormKey.currentState.validate()) {
      signUpFormKey.currentState.save();
      userModel.email = email;
      userModel.firstName = firstName;
      userModel.lastName = lastName;
      userModel.password = password;
      userModel.phoneNumber = phoneNumber;

      apiController.signUp(userModel);
    }
  }

  // updateUserName() {
  //   updateUserNameFormKey.currentState.save();
  //   if (updateUserNameFormKey.currentState.validate()) {
  //     userData.userName = userName;
  //     dbController.updateUserName(userData);
  //     update();
  //     Get.back();
  //   }
  // }

  // forgotPassword() {
  //   forgotFormKey.currentState.save();
  //   if (forgotFormKey.currentState.validate()) {
  //     print('Form validate');
  //     try {
  //       loadingController.showLoading();
  //       _auth.sendPasswordResetEmail(email: email);
  //       loadingController.stopLoading();
  //       loadingController.loadingSuccess();
  //       Get.back();
  //     } catch (error) {
  //       errorMessageforForgotPage = error.message;
  //       loadingController.stopLoading();

  //       update();
  //     }
  //   } else {
  //     print('Form is not validate');
  //   }
  // }

  clear() {
    errorList.clear();
  }
}
