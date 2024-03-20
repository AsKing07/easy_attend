import 'package:flutter/material.dart';

class SignUpProf extends StatefulWidget {
  const SignUpProf({super.key});

  @override
  State<SignUpProf> createState() => _SignUpProfState();
}

class _SignUpProfState extends State<SignUpProf> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminPinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
