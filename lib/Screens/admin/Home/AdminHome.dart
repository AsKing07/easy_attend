// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:easy_attend/Screens/admin/Home/AdminHomeMobile.dart';
import 'package:easy_attend/Screens/admin/Home/AdminHomeWeb.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        //Large screen
        ? const AdminHomeWeb()
        : const AdminHomeMobile();
//Small screen
  }
}
