// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Screens/etudiant/EtudiantHome.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class auth_methods_etudiant {
  Future logStudentIn(
      String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        var userSnapshot = await FirebaseFirestore.instance
            .collection("etudiant")
            .doc(uid)
            .get();

        if (userSnapshot.exists) {
          if (userSnapshot.data()!["statut"] == "0") {
            Navigator.pop(context);

            Helper().notAuthorizedMessage(context);
            FirebaseAuth.instance.signOut();
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const EtudiantHome()));
          }
        } else {
          Navigator.pop(context);

          Helper().notAuthorizedMessage(context);
          FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Helper().badCredential(context);
    }
  }

  void requestProfAccount(BuildContext context) {
    //Remplacer plus tard par effectuer une requette lorsque la logique des requette sera codée

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
