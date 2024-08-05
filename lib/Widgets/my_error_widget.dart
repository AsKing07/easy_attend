// ignore_for_file: must_be_immutable, camel_case_types

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class myErrorWidget extends StatefulWidget {
  myErrorWidget({super.key, required this.content});

  String content;

  @override
  State<myErrorWidget> createState() => _myErrorWidgetState();
}

class _myErrorWidgetState extends State<myErrorWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GFToast.showToast(widget.content, context,
        trailing: const Icon(Icons.close),
        toastPosition: screenWidth > 1200
            ? GFToastPosition.TOP_RIGHT
            : GFToastPosition.TOP,
        backgroundColor: AppColors.redColor);
  }
}
