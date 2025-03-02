import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader {
  static void showLoader(BuildContext context) {
    showDialog(
      barrierColor: Color(0xFF33A4BB),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.beat(
            color: Colors.white,
            size: 100,
          ),
        );
      },
    );
  }

  static void hideLoader(BuildContext context) {
    Navigator.pop(context);
  }
}
