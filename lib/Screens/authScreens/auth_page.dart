import 'package:easy_attend/Screens/authScreens/auth_page_mobile.dart';
import 'package:easy_attend/Screens/authScreens/auth_page_web.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1200
        //Mobile screen
        ? const AuthPageMobile()
        :
        //Grand Ecran
        const AuthPageWeb();
  }
}
