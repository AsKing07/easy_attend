import 'package:easy_attend/Screens/professeur/Login/login_prof_mobile.dart';
import 'package:easy_attend/Screens/professeur/Login/login_prof_web.dart';
import 'package:flutter/material.dart';

class LoginProf extends StatefulWidget {
  const LoginProf({super.key});

  @override
  State<LoginProf> createState() => _LoginProfState();
}

class _LoginProfState extends State<LoginProf> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const LoginProfWeb()
        : const LoginProfMobile();
  }
}
