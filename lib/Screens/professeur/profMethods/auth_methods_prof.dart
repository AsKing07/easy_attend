// ignore_for_file: use_build_context_synchronously, camel_case_types, unused_catch_clause

import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ProfHome.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class auth_methods_prof {
  final BACKEND_URL = dotenv.env['API_URL'];

  Future logProfIn(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.secondaryColor, size: 100)));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/prof/getProfById/$uid'),
      );

      Map<String, dynamic> prof = jsonDecode(response.body);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        if (prof["statut"] == "0") {
          Navigator.pop(context);

          Helper().notAuthorizedMessage(context);
          FirebaseAuth.instance.signOut();
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ProfHome()));
        }
      } else {
        Navigator.pop(context);

        Helper().notAuthorizedMessage(context);
        FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Helper().badCredential(context);
    }
  }
  // Future logProfIn(String email, String password, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //           child: LoadingAnimationWidget.hexagonDots(
  //               color: AppColors.secondaryColor, size: 100)));
  //   try {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email.trim(),
  //       password: password,
  //     );
  //     final uid = FirebaseAuth.instance.currentUser!.uid;
  //     var userSnapshot =
  //         await FirebaseFirestore.instance.collection("prof").doc(uid).get();
  //     if (userSnapshot.exists) {
  //       if (userSnapshot.data()!["statut"] == "0") {
  //         Navigator.pop(context);
  //         Helper().notAuthorizedMessage(context);
  //         FirebaseAuth.instance.signOut();
  //       } else {
  //         Navigator.pushReplacement(context,
  //             MaterialPageRoute(builder: (context) => const ProfHome()));
  //       }
  //     } else {
  //       Navigator.pop(context);
  //       Helper().notAuthorizedMessage(context);
  //       FirebaseAuth.instance.signOut();
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     Navigator.pop(context);
  //     Helper().badCredential(context);
  //   }
  // }

  void requestProfAccount(BuildContext context) {
    //Remplacer plus tard par effectuer une requette lorsque la logique des requette sera coder

    showDialog(
      context: context,
      builder: (context) {
        return WarningWidget(
          title: "Demande",
          content: "Contactez un admin pour votre inscription",
          height: 140,
        );
      },
    );
  }
}
