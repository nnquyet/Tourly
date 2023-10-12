import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowToast {
  final String text;

  const ShowToast({
    required this.text,
  });

  void show() {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color.fromRGBO(1, 1, 1, 0.7),
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }
}
