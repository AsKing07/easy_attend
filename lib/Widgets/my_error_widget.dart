// ignore_for_file: must_be_immutable, camel_case_types

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';

class myErrorWidget extends StatefulWidget {
  myErrorWidget({super.key, required this.content, required this.height});

  String content;
  double height;

  @override
  State<myErrorWidget> createState() => _myErrorWidgetState();
}

class _myErrorWidgetState extends State<myErrorWidget> {
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
                    Icons.error,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Erreur",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: AppColors.redColor),
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
            style: TextStyle(color: AppColors.redColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
}
