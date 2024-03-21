// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Screens/professeur/ProfHome.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class connexion_methods_prof {
  Future logProfIn(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        var userSnapshot =
            await FirebaseFirestore.instance.collection("prof").doc(uid).get();

        if (userSnapshot.exists) {
          if (userSnapshot.data()!["statut"] == "0") {
            Navigator.pop(context);

            notProfMessage(context);
            FirebaseAuth.instance.signOut();
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ProfHome()));
          }
        } else {
          Navigator.pop(context);

          notProfMessage(context);
          FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      badCredential(context);
    }
  }

  //  affiche un message  invalide si un mauvais e-mail ou mdp est fourni
  void badCredential(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Veuillez vérifier vos informations de connexion.",
            height: 150);
      },
    );
  }

  void notProfMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content:
                "Désolé, vous n'êtes pas autorisé(e) à accéder à cette page.",
            height: 180);
      },
    );
  }

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
