// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/admin/AdminHome.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:easy_attend/Widgets/helper.dart';
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
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        print('Une erreur s\'est produite lors de l\'inscription : $e');
        Helper().ErrorMessage(context);
      }
    }
  }

//LogIn Admin
  Future logAdminIn(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = await FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        var userSnapshot =
            await FirebaseFirestore.instance.collection("admin").doc(uid).get();

        if (userSnapshot.exists) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminHome()),
              (route) => false);
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

//Ajouter 1 prof
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
        final Ref = _db.collection("prof").doc(uid);
        await addUserDetails(nom, prenom, email, phone, Ref);
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
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        print('Une erreur s\'est produite lors de l\'inscription : $e');
        Helper().ErrorMessage(context);
      }
    }
  }

//Ajouter 1 étudiant
  Future<void> addOneStudent(Etudiant etudiant, BuildContext context) async {
    try {
      showDialog(
          context: context,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));

      final docSnapshot = await FirebaseFirestore.instance
          .collection('etudiant')
          .where('matricule', isEqualTo: etudiant.matricule)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        // L' étudiant existe déjà, afficher un message d'erreur
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return myErrorWidget(
                content: "Un étudiant avec le même matricule existe déjà.",
                height: 160);
          },
        );
      } else {
        // Création de l'etudiant
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: etudiant.email.trim(),
          password: etudiant.password.trim(),
        );

        // Connexion de l'étudiant
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: etudiant.email,
          password: etudiant.password,
        );

        // Obtention de l'UID de l'étudiant
        String? uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid != null) {
          FirebaseFirestore _db = FirebaseFirestore.instance;

          // L'étudiant n'existe pas encore, ajouter
          await FirebaseFirestore.instance.collection('etudiant').doc(uid).set({
            'nom': etudiant.nom.toUpperCase(),
            'prenom': etudiant.prenom.toUpperCase(),
            'matricule': etudiant.matricule.toUpperCase(),
            'phone': etudiant.phone.toUpperCase(),
            'filiere': etudiant.filiere.toUpperCase(),
            'idFiliere': etudiant.idFiliere,
            'niveau': etudiant.niveau.toUpperCase(),
            'statut': etudiant.statut.toUpperCase(),
          }).then((value) {
            // Etudiant ajouté avec succès
            Navigator.pop(context);
            Helper().succesMessage(context);
          }).catchError((error) {
            // Une erreur s'est produite lors de l'ajout du cours
            print(error);
            Navigator.pop(context);
            Helper().ErrorMessage(context);
          });
        }
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
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        print('Une erreur s\'est produite lors de l\'inscription : $e');
        Helper().ErrorMessage(context);
      }
    }
  }

  //log out user method
  void logUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => AuthPage()), (route) => false);
  }

//HELPER
  Future addUserDetails(
      String nom, String prenom, String email, String phone, final ref) async {
    await ref.set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
    });
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
}
