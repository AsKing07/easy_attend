// ignore_for_file: must_be_immutable

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';

class WarningWidget extends StatefulWidget {
  WarningWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.height});
  String title;
  String content;
  double height;

  @override
  State<WarningWidget> createState() => _WarningWidgetState();
}

class _WarningWidgetState extends State<WarningWidget> {
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
              Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.orange),
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
            style: TextStyle(color: Colors.orange),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
}
