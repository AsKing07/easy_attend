// ignore_for_file: must_be_immutable

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class SuccessWidget extends StatefulWidget {
  SuccessWidget({
    super.key,
    required this.content,
  });

  String content;

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GFToast.showToast(widget.content, context,
        trailing: const Icon(Icons.check_box_rounded),
        toastPosition: screenWidth > 1200
            ? GFToastPosition.TOP_RIGHT
            : GFToastPosition.TOP,
        toastDuration: 8,
        backgroundColor: AppColors.greenColor);
  }
}
