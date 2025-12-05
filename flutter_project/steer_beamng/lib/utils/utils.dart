import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Utils {
  static Future<bool> checkInternetConnection() async {
    bool value = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        value = true;
      }
    } on SocketException catch (_) {
      value = false;
    }
    return value;
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

}
