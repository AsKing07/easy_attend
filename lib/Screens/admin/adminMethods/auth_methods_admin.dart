// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/admin/AdminHome.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/my_success_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:excel/excel.dart';

class auth_methods_admin {
  static Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);

    await app.delete();
    return Future.sync(() => userCredential);
  }

//Fonctions de création de l'utilisateur admin
  Future signUp(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
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
        await addUserDetails(nom.toUpperCase().trim(),
            prenom.toUpperCase().trim(), email, phone, adminRef, null);

        // Redirection vers la page d'accueil de l'admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
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
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = await FirebaseAuth.instance.currentUser!.uid;
      var userSnapshot =
          await FirebaseFirestore.instance.collection("admin").doc(uid).get();

      if (userSnapshot.exists) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminHome()),
            (route) => false);
      } else {
        Navigator.pop(context);
        Helper().notAuthorizedMessage(context);
        FirebaseAuth.instance.signOut();
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
        Helper().badCredential(context);
      }
    }
  }

//METHODE DES PROFS

//Ajouter 1 prof
  Future createProf(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      print(FirebaseAuth.instance.currentUser!.uid);

      // Création du prof
      UserCredential userCredential = await register(email, password);
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email.trim(),
      //   password: password.trim(),
      // );

      // Obtention de l'UID du prof
      String? uid = userCredential.user?.uid;

      print(FirebaseAuth.instance.currentUser!.uid);

      if (uid != null) {
        // Ajout des détails du prof
        FirebaseFirestore _db = FirebaseFirestore.instance;
        final Ref = _db.collection("prof").doc(uid);
        await addUserDetails(nom.toUpperCase().trim(),
            prenom.toUpperCase().trim(), email, phone, Ref, null);
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

//METHODES DES ETUDIANTS

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
        UserCredential userCredential =
            await register(etudiant.email!.trim(), etudiant.password!.trim());
        // await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //   email: etudiant.email.trim(),
        //   password: etudiant.password.trim(),
        // );

        // Obtention de l'UID de l'étudiant
        String? uid = userCredential.user?.uid;

        if (uid != null) {
          // L'étudiant n'existe pas encore, ajouter
          await FirebaseFirestore.instance.collection('etudiant').doc(uid).set({
            'nom': etudiant.nom.toUpperCase().trim(),
            'prenom': etudiant.prenom.toUpperCase().trim(),
            'matricule': etudiant.matricule.toUpperCase().trim(),
            'phone': etudiant.phone.toUpperCase().trim(),
            'filiere': etudiant.filiere.toUpperCase().trim(),
            'idFiliere': etudiant.idFiliere!.trim(),
            'niveau': etudiant.niveau.toUpperCase().trim(),
            'statut': etudiant.statut.toUpperCase().trim(),
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

//Ajout d'un étudiant récupérer depuis un fichier excel
  Future<void> addStudentTookFromExcel(
      Etudiant etudiant, BuildContext context) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('etudiant')
        .where('matricule', isEqualTo: etudiant.matricule)
        .get();

    if (docSnapshot.docs.isEmpty) {
      // Création de l'etudiant
      UserCredential userCredential =
          await register(etudiant.email!.trim(), etudiant.password!.trim());

      String? uid = userCredential.user?.uid;

      if (uid != null) {
        // L'étudiant n'existe pas encore, ajouter
        await FirebaseFirestore.instance.collection('etudiant').doc(uid).set({
          'nom': etudiant.nom.toUpperCase().trim(),
          'prenom': etudiant.prenom.toUpperCase().trim(),
          'matricule': etudiant.matricule.toUpperCase().trim(),
          'phone': etudiant.phone.toUpperCase().trim(),
          'filiere': etudiant.filiere.toUpperCase().trim(),
          'idFiliere': etudiant.idFiliere!.trim(),
          'niveau': etudiant.niveau.toUpperCase().trim(),
          'statut': etudiant.statut.toUpperCase().trim(),
        });
      }
    }
  }

//Add multiple Students from excel
  Future<void> addMultipleStudent(String filePath, BuildContext context) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];

    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // Vérifiez que les colonnes attendues sont présentes dans le fichier Excel
    final expectedColumns = [
      'Matricule',
      'Nom',
      'Prenom',
      'Email',
      'Password',
      'Phone',
      'Filiere',
      'Niveau'
    ];
    final headerRow =
        sheet!.rows.first.map((cell) => cell!.value.toString().trim()).toList();
    // for (var cell in headerRow) {
    //   print(
    //       cell.toUpperCase()); // Affiche chaque valeur de cellule de l'en-tête
    // }

    if (!headerRow.every((cell) => expectedColumns.contains(cell))) {
      // throw Exception(
      //     'Le fichier Excel ne contient pas les colonnes attendues.');
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return myErrorWidget(
              content:
                  "Le fichier Excel ne contient pas les colonnes attendues.",
              height: 160);
        },
      );
    } else {
      for (var i = 1; i < sheet.rows.length; i++) {
        try {
          final row = sheet.rows[i];
          final filiereName = row[6]!.value.toString();

          QuerySnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
              .instance
              .collection('filiere')
              .where('nomFiliere', isEqualTo: filiereName.toUpperCase())
              .limit(1)
              .get();
          String idFiliere = doc.docs.first.id;
          print(idFiliere);
          print(filiereName);

          final etudiant = Etudiant(
              matricule: row[0]!.value.toString().toUpperCase().trim(),
              nom: row[1]!.value.toString().toUpperCase().trim(),
              prenom: row[2]!.value.toString().toUpperCase().trim(),
              email: row[3]!.value.toString().trim(),
              password: row[4]!.value.toString().trim(),
              phone: row[5]!.value.toString().toUpperCase().trim(),
              idFiliere: idFiliere.trim(),
              filiere: row[6]!.value.toString().toUpperCase().trim(),
              niveau: row[7]!.value.toString().toUpperCase().trim(),
              statut: "1");

          await addStudentTookFromExcel(etudiant, context);
        } catch (e) {
          Navigator.pop(context);
          print(
              'Une erreur s\'est produite lors de l\'ajout depuis excel : $e');
          // Helper().ErrorMessage(context);
          showDialog(
            context: context,
            builder: (context) {
              return myErrorWidget(
                  content:
                      "L'opération s'est déroulée avec des erreurs. Veuillez vérifier le résultat",
                  height: 160);
            },
          );
        }
      }

      Navigator.pop(context);
      Helper().succesMessage(context);
    }
  }

//HELPER
  Future addUserDetails(String nom, String prenom, String email, String phone,
      final ref, String? statut) async {
    await ref.set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
      'statut': statut != null ? statut : "1"
    });
  }

  //log out user method
  void logUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false);
  }
}
