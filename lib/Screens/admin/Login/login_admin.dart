import 'package:easy_attend/Screens/admin/Login/login_admin_mobile.dart';
import 'package:easy_attend/Screens/admin/Login/login_admin_web.dart';

import 'package:flutter/material.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const LoginAdmonWeb()
        : const LoginAdminMobile();
  }
}
