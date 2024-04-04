import 'package:easy_attend/Config/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

// import '../../components/my_button.dart';
// import '../../components/utils.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'Changer mot de passe',
          style: TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
        child: SingleChildScrollView(
          //scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () async {
                    auth
                        .sendPasswordResetEmail(
                            email: emailController.text.toString())
                        .then((value) {
                      GFToast.showToast(
                          'Si vous êtes inscrit(e), un e-mail de récupération a été envoyé à votre adresse e-mail. Consultez également vos spam.',
                          context,
                          toastDuration: 6);
                    }).onError((error, stackTrace) {
                      GFToast.showToast(error.toString(), context,
                          toastDuration: 15);
                    });
                  },
                  child: const Text('Envoyer Email de récupération'))
            ],
          ),
        ),
      ),
    );
  }
}
