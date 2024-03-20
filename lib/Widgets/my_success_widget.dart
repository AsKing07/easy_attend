// ignore_for_file: must_be_immutable

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';

class SuccessWidget extends StatefulWidget {
  SuccessWidget({super.key, required this.content, required this.height});

  String content;
  double height;

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: widget.height,
        width: 30.0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_outlined,
                    color: AppColors.greenColor,
                  ),
                  Text(
                    "Succes",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: AppColors.greenColor),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.content,
                style: const TextStyle(
                  fontSize: FontSize.medium,
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
      actions: [
        okButton(),
      ],
    );
  }

  Widget okButton() => Center(
        child: ElevatedButton(
          child: const Text(
            "OK",
            style: TextStyle(color: AppColors.greenColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
}
