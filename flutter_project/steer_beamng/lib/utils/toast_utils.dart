import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void _show(String message, Color bg) {
    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: bg,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void infoToast(String message) {
    _show(message, Colors.grey.shade600);
  }

  static void failureToast(String message) {
    _show(message, Colors.red.shade600);
  }

  static void successToast(String message) {
    _show(message, Colors.green.shade600);
  }
}
