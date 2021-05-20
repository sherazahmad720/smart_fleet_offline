import 'package:flutter/material.dart';
import 'package:get/get.dart';

Color blueColor = Color(0xff0088cc);
Color darkColor = Color(0xff333333);
int toatlAvatarAmount = 24;
Color avatarBackGround = Color(0xff65c9ff);
BuildContext tomContext;
Color messageColorForSender =
    Get.isDarkMode ? Color(0xffb4a5a5) : Color(0xffC5E1E4);
Color messageColorForReceiver =
    Get.isDarkMode ? Color(0xff301b3f) : Color(0xffB7c098);
String createGroupWarning =
    '*- After Creating a Group you Cant add user\n*- First admin have to approve the group then you can chat\n *- every user have to put code to join group';
Color groupChatIconColor(String txt) {
  String latter = txt.split('')[0];
  if (latter.toLowerCase() == 'a' ||
      latter.toLowerCase() == 'e' ||
      latter.toLowerCase() == 'i' ||
      latter.toLowerCase() == 'm' ||
      latter.toLowerCase() == 'q' ||
      latter.toLowerCase() == 'u' ||
      latter.toLowerCase() == 'y') {
    return Colors.red;
  } else if (latter.toLowerCase() == 'b' ||
      latter.toLowerCase() == 'f' ||
      latter.toLowerCase() == 'j' ||
      latter.toLowerCase() == 'n' ||
      latter.toLowerCase() == 'r' ||
      latter.toLowerCase() == 'v' ||
      latter.toLowerCase() == 'z') {
    return Colors.blue;
  } else if (latter.toLowerCase() == 'c' ||
      latter.toLowerCase() == 'g' ||
      latter.toLowerCase() == 'k' ||
      latter.toLowerCase() == 'o' ||
      latter.toLowerCase() == 's' ||
      latter.toLowerCase() == 'w') {
    return Colors.pink;
  } else {
    return Colors.orangeAccent;
  }
}
