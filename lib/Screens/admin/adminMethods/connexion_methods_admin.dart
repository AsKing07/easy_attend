// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/AdminHome.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/my_success_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';

class connexion_methods_admin {
  //Fonctions de création de l'utilisateur admin
  Future signUp(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      // Création de l'utilisateur
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Connexion de l'utilisateur
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtention de l'UID de l'utilisateur actuel
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // Ajout des détails de l'utilisateur
        FirebaseFirestore _db = FirebaseFirestore.instance;
        final adminRef = _db.collection("admin").doc(uid);
        await addUserDetails(nom, prenom, email, phone, adminRef);

        // Redirection vers la page d'accueil de l'admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      } else {
        print('Impossible d\'obtenir l\'UID de l\'utilisateur.');
      }
    } catch (e) {
      Navigator.pop(context);
      // Gérer l'erreur d'inscription ici
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          // L'email est déjà utilisé, afficher un message à l'utilisateur

          GFToast.showToast(
              'Un utilisateur avec cet email existe déjà', context,
              backgroundColor: Colors.white,
              textStyle: const TextStyle(color: Colors.red),
              toastDuration: 6);
        } else {
          // Gérer les autres erreurs Firebase
          print('Une erreur s\'est produite lors de l\'inscription : $e');
          errorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        print('Une erreur s\'est produite lors de l\'inscription : $e');
        errorMessage(context);
      }
    }
  }

  Future addUserDetails(
      String nom, String prenom, String email, String phone, final ref) async {
    await ref.set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
    });
  }

  //Méthodes de connexion admin

  Future logAdminIn(String email, String password, BuildContext context) async {
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
      final uid = await FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        var userSnapshot =
            await FirebaseFirestore.instance.collection("admin").doc(uid).get();

        if (userSnapshot.exists) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AdminHome()));
        } else {
          Navigator.pop(context);
          notAdminMessage(context);
          FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      Navigator.pop(context);
      if (e.code == 'network-request-failed') {
        GFToast.showToast('Veuillez vérifier votre connexion internet', context,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.red),
            toastDuration: 3);
      } else {
        badCredential(context);
      }
    }
  }

  Future createProf(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      // Création du prof
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Connexion du prof
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtention de l'UID du prof
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // Ajout des détails du prof
        FirebaseFirestore _db = FirebaseFirestore.instance;
        final adminRef = _db.collection("prof").doc(uid);
        await addUserDetails(nom, prenom, email, phone, adminRef);
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return SuccessWidget(
              content: "L'ajout a été un success",
              height: 100,
            );
          },
        );
      } else {
        print('Impossible d\'obtenir l\'UID de l\'utilisateur.');
      }
    } catch (e) {
      Navigator.pop(context);
      // Gérer l'erreur d'inscription ici
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          // L'email est déjà utilisé, afficher un message à l'utilisateur

          GFToast.showToast(
              'Un utilisateur avec cet email existe déjà', context,
              backgroundColor: Colors.white,
              textStyle: const TextStyle(color: Colors.red),
              toastDuration: 6);
        } else {
          // Gérer les autres erreurs Firebase
          print('Une erreur s\'est produite lors de l\'inscription : $e');
          errorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        print('Une erreur s\'est produite lors de l\'inscription : $e');
        errorMessage(context);
      }
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

  void notAdminMessage(BuildContext context) {
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

  void errorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Une erreur inconnue s'est produite.", height: 180);
      },
    );
  }

  //log out user method
  void logUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }
}
