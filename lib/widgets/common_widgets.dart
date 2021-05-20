import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget customText(txt, {double size = 16, Color color, bool isBold = false}) {
  return Text(txt,
      style: TextStyle(
          color: color == null
              ? Get.isDarkMode
                  ? Colors.white
                  : Colors.black
              : color,
          fontSize: size,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal));
}

Widget customInputTextfield(
    {controller,
    onSave,
    enabled = true,
    validator,
    suffixPressed,
    label = 'First',
    isPasswordField = false,
    isPasswordShow = false,
    keyBoardType = TextInputType.text}) {
  return TextFormField(
    controller: controller,
    onSaved: onSave,
    validator: validator,
    enabled: enabled,
    obscureText: isPasswordField ? !isPasswordShow : false,
    decoration: InputDecoration(

        // errorMaxLines: 3,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.deepOrange)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.deepOrange)),
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange),
        suffix: isPasswordField
            ? InkWell(
                onTap: suffixPressed,
                child: Icon(
                  !isPasswordShow ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null),
  );
}

Widget customButton(
    {txt,
    bgColor = Colors.deepOrange,
    txtColor = Colors.white,
    onpressed,
    elvation = true}) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: bgColor, elevation: elvation ? 4 : 0),
      onPressed: onpressed,
      child: (Text(
        txt,
        style: TextStyle(color: txtColor),
      )));
}

var space20 = SizedBox(
  height: 20,
  width: 20,
);
var space10 = SizedBox(
  height: 10,
  width: 10,
);
var space5 = SizedBox(
  height: 5,
  width: 5,
);
var space15 = SizedBox(
  height: 15,
  width: 15,
);
var space30 = SizedBox(
  height: 30,
  width: 30,
);
