import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/pages/login_screen.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  AuthController authController = Get.find();
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
                key: controller.signUpFormKey,
                child: SingleChildScrollView(
                  child: Container(
                    height: Get.height - 200,
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

                        space10,
                        customInputTextfield(
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
                        space10,
                        customInputTextfield(
                            validator: controller.nameValidator,
                            label: 'First Name',
                            keyBoardType: TextInputType.text,
                            onSave: (val) {
                              controller.firstName = val;
                            }),
                        space10,
                        customInputTextfield(
                            label: 'Last Name',
                            validator: controller.nameValidator,
                            keyBoardType: TextInputType.text,
                            onSave: (val) {
                              controller.lastName = val;
                            }),
                        space10,
                        customInputTextfield(
                            validator: controller.phoneValidator,
                            label: 'Phone Number',
                            keyBoardType: TextInputType.number,
                            onSave: (val) {
                              controller.phoneNumber = val;
                            }),
                        space10,
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
                        space10,

                        Spacer(),
                        Row(
                          children: [
                            Expanded(
                                child: customButton(
                                    txt: 'Sign Up',
                                    onpressed: () {
                                      controller.signUp();
                                    })),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                                child: customButton(
                                    onpressed: () {
                                      Get.off(LoginPage(),
                                          preventDuplicates: false);
                                    },
                                    txt: 'Login',
                                    bgColor: Colors.transparent,
                                    txtColor: Colors.grey,
                                    elvation: false)),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ),
        );
      },
    );
  }
}
