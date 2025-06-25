import 'package:flutter/material.dart';

import 'main.dart';
import 'my_progress_dialog.dart';

class Utils {

  static showProgressDialog(
      {required BuildContext context, String? text = 'Cargando...'}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => MyProgressDialog(text: text));
  }

  static closeDialog({required BuildContext context}) {
    if (context != null) {
      Navigator.of(context).pop();
    }
  }
}
