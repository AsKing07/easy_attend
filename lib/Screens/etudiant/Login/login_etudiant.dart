import 'package:easy_attend/Screens/etudiant/Login/login_etudiant_mobile.dart';
import 'package:easy_attend/Screens/etudiant/Login/login_etudiant_web.dart';

import 'package:flutter/material.dart';

class LoginStudent extends StatefulWidget {
  const LoginStudent({super.key});

  @override
  State<LoginStudent> createState() => _LoginStudentState();
}

class _LoginStudentState extends State<LoginStudent> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const LoginEtudiantWeb()
        : const LoginEtudiantMobile();
  }
}
