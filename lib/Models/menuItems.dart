// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MenuItems {
  String text;
  IconData icon;
  Widget tap;
  bool isSelected;
  MenuItems(
      {required this.text,
      required this.icon,
      required this.tap,
      this.isSelected = false});
}
