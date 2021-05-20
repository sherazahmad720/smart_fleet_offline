import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/connectivity_controller.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/pages/signup_screen.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  AuthController authController = Get.put(AuthController());
  DbController dbController = Get.find();
  @override
  Widget build(BuildContext context) {
    authController.clear();

    return GetBuilder<AuthController>(
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            body: Container(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
                    // space20,
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customText(
                          'Smart Fleet',
                          size: 35,
                          isBold: true,
                        ),
                      ],
                    ),
                    Spacer(),
                    customInputTextfield(
                        controller: dbController.localEmailController,
                        enabled: dbController.localEmail == '',
                        validator: controller.emailValidator,
                        label: 'Email',
                        keyBoardType: TextInputType.emailAddress,
                        onSave: (val) {
                          controller.email = val;
                        }),
                    space10,
                    customInputTextfield(
                        label: 'Password',
                        isPasswordField: true,
                        validator: controller.passwordValidator,
                        onSave: (val) {
                          controller.password = val;
                        },
                        isPasswordShow: controller.isPasswordShow,
                        suffixPressed: () {
                          controller.isPasswordShow
                              ? controller.isPasswordShow = false
                              : controller.isPasswordShow = true;
                          controller.update();
                        }),
                    // space10,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     InkWell(
                    //       onTap: () {
                    //         // Get.to(ForgotPage());
                    //       },
                    //       child: customText('Forgot Password ?',
                    //           size: 14, isBold: true, color: Colors.grey),
                    //     ),
                    //   ],
                    // ),
                    space10,
                    // if (controller.errorMessageforLogin != null)
                    //   Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       Flexible(
                    //         child: customText(controller.errorMessageforLogin,
                    //             size: 12, color: Colors.red),
                    //       ),
                    //     ],
                    //   ),
                    // space10,
                    // if (controller.errorMessageforSignUp != null)
                    for (var error in controller.errorList)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: customText(error.toString(),
                                size: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                            child: customButton(
                                txt: 'Login',
                                onpressed: () {
                                  controller.login();
                                })),
                      ],
                    ),
                    if (dbController.localEmail == '')
                      Row(
                        children: [
                          Expanded(
                              child: customButton(
                                  onpressed: () {
                                    Get.off(SignUpPage());
                                    // ConnectivityController().checkInternet();
                                  },
                                  txt: 'Create Account',
                                  bgColor: Colors.transparent,
                                  txtColor: Colors.grey,
                                  elvation: false)),
                        ],
                      ),
                    Spacer(),
                  ],
                ),
              ),
            )),
          ),
        );
      },
    );
  }
}
