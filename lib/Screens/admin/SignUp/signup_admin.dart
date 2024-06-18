// ignore_for_file: sized_box_for_whitespace

import 'package:easy_attend/Screens/admin/SignUp/signUpAdminMobile.dart';
import 'package:easy_attend/Screens/admin/SignUp/signUpAdminWeb.dart';
import 'package:flutter/material.dart';

class SignUpAdmin extends StatefulWidget {
  const SignUpAdmin({super.key});

  @override
  State<SignUpAdmin> createState() => _SignUpAdminState();
}

class _SignUpAdminState extends State<SignUpAdmin> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const SignUpAdminWeb()
        : const SignUpAdminMobile();
  }
}
