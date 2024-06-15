// ignore_for_file: non_constant_identifier_names

import 'package:easy_attend/Config/styles.dart';

import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:flutter/material.dart';

import 'package:getwidget/getwidget.dart';

class Helper {
  void show_custom_message(
      String message, double height, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningWidget(
            title: "Information", content: message, height: height);
      },
    );
  }

  void succesMessage(BuildContext context, {String? content}) {
    // double screenWidth = MediaQuery.of(context).size.width;

    GFToast.showToast(content ?? "Fait avec succès", context,
        trailing: const Icon(
          Icons.check_box_rounded,
          color: AppColors.white,
        ),
        toastDuration: 8,
        backgroundColor: AppColors.greenColor);
  }

  void ErrorMessage(BuildContext context, {String? content}) {
    // double screenWidth = MediaQuery.of(context).size.width;
    GFToast.showToast(
        toastDuration: 8,
        content ?? "Oups... quelque chose s'est mal passé",
        context,
        trailing: const Icon(
          Icons.close,
          color: AppColors.white,
        ),
        // toastPosition: screenWidth > 1200
        //     ? GFToastPosition.TOP_RIGHT
        //     : GFToastPosition.TOP,
        backgroundColor: AppColors.redColor);
  }
}
