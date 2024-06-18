// ignore_for_file: use_build_context_synchronously, camel_case_types, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/admin/Home/AdminHome.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:excel/excel.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class auth_methods_admin {
  final BACKEND_URL = dotenv.env['API_URL'];

  static Future<UserCredential> register(
      String email, String password, FirebaseApp? app) async {
    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app!)
        .createUserWithEmailAndPassword(email: email, password: password);

    // await app.delete();

    return Future.sync(() => userCredential);
  }

//Fonctions de création de l'utilisateur admin

  Future signUp(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: LoadingAnimationWidget.hexagonDots(
            color: AppColors.secondaryColor,
            size: 100,
          ),
        ),
      );
      // Création de l'utilisateur
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());

      // Obtention de l'UID de l'utilisateur actuel
      String? uid = userCredential.user?.uid;

      if (uid != null) {
        // Ajout des détails de l'utilisateur

        // Envoi des informations de l'utilisateur au backend
        await sendUserDataToBackend(uid, nom, prenom, phone, userCredential);
        http.Response response = await http.get(
          Uri.parse('$BACKEND_URL/api/admin/$uid'),
        );

        Map<String, dynamic> admin = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("loggedIn", true);
        prefs.setString("role", "admin");
        prefs.setString("user", json.encode(admin));
        // Redirection vers la page d'accueil de l'admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        Helper().ErrorMessage(context);
        // print('Impossible d\'obtenir l\'UID de l\'utilisateur.');
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
          // print('Une erreur s\'est produite lors de l\'inscription : $e');
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        // print('Une erreur s\'est produite lors de l\'inscription : $e');
        Helper().ErrorMessage(context);
      }
    }
  }

  Future sendUserDataToBackend(String uid, String nom, String prenom,
      String phone, UserCredential credential) async {
    try {
      // Création de l'objet de données à envoyer au backend
      Map<String, dynamic> data = {
        'uid': uid,
        'email': credential.user?.email,
        'nom': nom,
        'prenom': prenom,
        'phone': phone,
      };

      // Envoi des données au backend
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/admin/createAdmin'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
      } else {
        // La requête a échoué, gérer l'erreur ici
      }
    } catch (e) {
      // Gérer l'erreur d'envoi des données au backend
    }
  }

//LogIn Admin
  Future<void> logAdminIn(
      String email, String password, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: AppColors.secondaryColor,
          size: 100,
        ),
      ),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/admin/$uid'),
      );

      Map<String, dynamic> admin = jsonDecode(response.body);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("loggedIn", true);
        prefs.setString("role", "admin");
        prefs.setString("user", json.encode(admin));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
        Helper().ErrorMessage(context,
            content:
                "Désolé, vous n'êtes pas autorisé(e) à accéder à cette page.");

        FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      Navigator.pop(context);
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          Helper().ErrorMessage(context,
              content: "Veuillez vérifier vos informations de connexion.");
        } else {
          Helper().ErrorMessage(context);
        }
      } else if (e is SocketException) {
        Helper().ErrorMessage(context,
            content: "Oups... veuillez vérifiez votre connexion internet");
      } else {
        Helper().ErrorMessage(context);
      }
    }
  }

  Future getAdminById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/admin/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici
        dynamic admin = jsonDecode(response.body);
        // Utiliser les données des profs ici
        return admin;
      } else {
        // La requête a échoué, gérer l'erreur ici
        Helper().ErrorMessage(context,
            content:
                "Une erreur est subvenue lors de la récupération des données");
      }
    } catch (e) {
      Helper().ErrorMessage(context,
          content:
              "Une erreur est subvenue lors de la récupération des données");
    }
  }

//METHODE DES PROFS

// Ajouter 1 prof
  Future createProf(String email, String password, String nom, String prenom,
      String phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    try {
      FirebaseApp firebaseApp = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      // Création du prof
      UserCredential userCredential =
          await register(email, password, firebaseApp);

      // Obtention de l'UID de l'utilisateur
      String? uid = userCredential.user?.uid;

      if (uid != null) {
        // Envoi des informations de l'utilisateur au backend pour enregistrement dans la base de données SQL
        http.Response response = await http.post(
          Uri.parse('$BACKEND_URL/api/prof/'),
          body: jsonEncode({
            'uid': uid,
            'nom': nom.toUpperCase().trim(),
            'prenom': prenom.toUpperCase().trim(),
            'email': email,
            'phone': phone,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
          Helper().succesMessage(context);
        } else {
          Navigator.pop(context);
          Helper().ErrorMessage(context);
        }
      } else {
        Navigator.pop(context);
        Helper().ErrorMessage(context);
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
          // print('Une erreur s\'est produite lors de l'inscription : $e');
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        // print('Une erreur s\'est produite lors de l'inscription : $e');
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
          builder: (context) => Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 200),
              ));

      http.Response response = await http.get(
        Uri.parse(
            '$BACKEND_URL/api/student/getStudentByMatricule?matricule=${etudiant.matricule}'),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // L' étudiant existe déjà, afficher un message d'erreur
        Navigator.pop(context);
        double screenWidth = MediaQuery.of(context).size.width;
        GFToast.showToast(
            "Un étudiant avec le même matricule existe déjà.", context,
            trailing: const Icon(Icons.close),
            toastPosition: screenWidth > 1200
                ? GFToastPosition.TOP_RIGHT
                : GFToastPosition.TOP,
            backgroundColor: AppColors.redColor);
      } else {
        FirebaseApp firebaseApp = await Firebase.initializeApp(
            name: 'Secondary', options: Firebase.app().options);
        // Création de l'etudiant
        UserCredential userCredential = await register(
            etudiant.email!.trim(), etudiant.password!.trim(), firebaseApp);
        // Obtention de l'UID de l'étudiant
        String? uid = userCredential.user?.uid;
        if (uid != null) {
          // Envoi des informations de l'utilisateur au backend pour enregistrement dans la base de données SQL
          http.Response response = await http.post(
            Uri.parse('$BACKEND_URL/api/student'),
            body: jsonEncode({
              'uid': uid,
              'email': etudiant.email!.trim(),
              'nom': etudiant.nom.toUpperCase().trim(),
              'prenom': etudiant.prenom.toUpperCase().trim(),
              'matricule': etudiant.matricule.toUpperCase().trim(),
              'phone': etudiant.phone.toUpperCase().trim(),
              'filiere': etudiant.filiere.toUpperCase().trim(),
              'idFiliere': etudiant.idFiliere!.trim(),
              'niveau': etudiant.niveau.toUpperCase().trim(),
              'statut': true,
            }),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200) {
            Navigator.pop(context);
            Helper().succesMessage(context);
          } else {
            Navigator.pop(context);
            Helper().ErrorMessage(context);
          }
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
          // print('Une erreur s\'est produite lors de l\'inscription : $e');
          Helper().ErrorMessage(context);
        }
      } else {
        // Gérer les autres erreurs
        // print('Une erreur s\'est produite lors de l\'inscription : $e');
        Helper().ErrorMessage(context);
      }
    }
  }
  // Future<void> addOneStudent(Etudiant etudiant, BuildContext context) async {
  //   try {
  //     showDialog(
  //         context: context,
  //         builder: (context) => Center(
  //               child: LoadingAnimationWidget.hexagonDots(
  //                   color: AppColors.secondaryColor, size: 200),
  //             ));
  //     final docSnapshot = await FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .where('matricule', isEqualTo: etudiant.matricule)
  //         .get();
  //     if (docSnapshot.docs.isNotEmpty) {
  //       // L' étudiant existe déjà, afficher un message d'erreur
  //       Navigator.pop(context);
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return myErrorWidget(
  //               content: "Un étudiant avec le même matricule existe déjà.",
  //               height: 160);
  //         },
  //       );
  //     } else {
  //       FirebaseApp firebaseApp = await Firebase.initializeApp(
  //           name: 'Secondary', options: Firebase.app().options);
  //       // Création de l'etudiant
  //       UserCredential userCredential = await register(
  //           etudiant.email!.trim(), etudiant.password!.trim(), firebaseApp);
  //       // Obtention de l'UID de l'étudiant
  //       String? uid = userCredential.user?.uid;
  //       if (uid != null) {
  //         // L'étudiant n'existe pas encore, ajouter
  //         await FirebaseFirestore.instance.collection('etudiant').doc(uid).set({
  //           'nom': etudiant.nom.toUpperCase().trim(),
  //           'prenom': etudiant.prenom.toUpperCase().trim(),
  //           'matricule': etudiant.matricule.toUpperCase().trim(),
  //           'phone': etudiant.phone.toUpperCase().trim(),
  //           'filiere': etudiant.filiere.toUpperCase().trim(),
  //           'idFiliere': etudiant.idFiliere!.trim(),
  //           'niveau': etudiant.niveau.toUpperCase().trim(),
  //           'statut': etudiant.statut.toUpperCase().trim(),
  //         }).then((value) {
  //           // Etudiant ajouté avec succès
  //           Navigator.pop(context);
  //           Helper().succesMessage(context);
  //         }).catchError((error) {
  //           // Une erreur s'est produite lors de l'ajout du cours
  //           // print(error);
  //           Navigator.pop(context);
  //           Helper().ErrorMessage(context);
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     Navigator.pop(context);
  //     // Gérer l'erreur d'inscription ici
  //     if (e is FirebaseAuthException) {
  //       if (e.code == 'email-already-in-use') {
  //         // L'email est déjà utilisé, afficher un message à l'utilisateur
  //         GFToast.showToast(
  //             'Un utilisateur avec cet email existe déjà', context,
  //             backgroundColor: Colors.white,
  //             textStyle: const TextStyle(color: Colors.red),
  //             toastDuration: 6);
  //       } else {
  //         // Gérer les autres erreurs Firebase
  //         // print('Une erreur s\'est produite lors de l\'inscription : $e');
  //         Helper().ErrorMessage(context);
  //       }
  //     } else {
  //       // Gérer les autres erreurs
  //       // print('Une erreur s\'est produite lors de l\'inscription : $e');
  //       Helper().ErrorMessage(context);
  //     }
  //   }
  // }

//Ajout d'un étudiant récupérer depuis un fichier excel
  Future<void> addStudentTookFromExcel(
      Etudiant etudiant, BuildContext context, FirebaseApp? app) async {
    http.Response response = await http.get(
      Uri.parse(
          '$BACKEND_URL/api/student/getStudentByMatricule?matricule=${etudiant.matricule}'),
    );

    if (response.statusCode == 404) {
      // Création de l'etudiant
      try {
        UserCredential userCredential =
            await register(etudiant.email!.trim(), etudiant.password!, app!);

        String? uid = userCredential.user?.uid;

        if (uid != null) {
          // L'étudiant n'existe pas encore, ajouter
          // Envoi des informations de l'utilisateur au backend pour enregistrement dans la base de données SQL
          await http.post(
            Uri.parse('$BACKEND_URL/api/student/'),
            body: jsonEncode({
              'uid': uid,
              'email': etudiant.email!.trim(),
              'nom': etudiant.nom.toUpperCase().trim(),
              'prenom': etudiant.prenom.toUpperCase().trim(),
              'matricule': etudiant.matricule.toUpperCase().trim(),
              'phone': etudiant.phone.toUpperCase().trim(),
              'filiere': etudiant.filiere.toUpperCase().trim(),
              'idFiliere': etudiant.idFiliere!.trim(),
              'niveau': etudiant.niveau.toUpperCase().trim(),
              'statut': true,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur innatendue : $e '),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

//Add multiple Students from excel on android
  Future<void> addMultipleStudent(String filePath, BuildContext context) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    int totalAjoute = 0;
    int totalErreur = 0;

    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
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
      double screenWidth = MediaQuery.of(context).size.width;
      GFToast.showToast(
          "Le fichier Excel ne contient pas les colonnes attendues.", context,
          trailing: const Icon(Icons.close),
          toastPosition: screenWidth > 1200
              ? GFToastPosition.TOP_RIGHT
              : GFToastPosition.TOP,
          backgroundColor: AppColors.redColor);
    } else {
      FirebaseApp firebaseApp = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      for (var i = 1; i < sheet.rows.length; i++) {
        try {
          final row = sheet.rows[i];
          final filiereName = row[6]!.value.toString();

          http.Response response = await http.get(
            Uri.parse('$BACKEND_URL/api/filiere/getFiliereByName/$filiereName'),
          );

          List<dynamic> filiere = jsonDecode(response.body);
          String idFiliere = filiere[0]['idFiliere'].toString();

          // print(idFiliere);
          // print(filiereName);

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
              statut: true);

          await addStudentTookFromExcel(etudiant, context, firebaseApp);
          totalAjoute++;
          // print(              "Matricule: ${etudiant.matricule} Nom: ${etudiant.nom} Prénom: ${etudiant.prenom} Email: ${etudiant.email} Password: ${etudiant.password}  Phone: ${etudiant.phone}  ID Filière: ${etudiant.idFiliere} Filière: ${etudiant.filiere} Niveau: ${etudiant.niveau} Statut: ${etudiant.statut}   ");
        } catch (e) {
          // print(e);
          totalErreur++;
          // print('An error occurred while adding from Excel: $e');
        }
      }

      if (totalErreur > 0) {
        Navigator.pop(context);
        Helper().show_custom_message(
            'L\'opération s\'est déroulée avec $totalErreur erreurs. \n $totalAjoute étudiants ajouté(s) ',
            220,
            context);
      } else {
        // print(totalAjoute);
        Navigator.pop(context);
        Helper().succesMessage(context);
      }
    }
  }

//Add multiple Students from excel on web
  Future<void> addMultipleStudentFromWeb(
      html.Blob fileBlob, BuildContext context) async {
    final reader = html.FileReader();
    int totalAjoute = 0;
    int totalErreur = 0;
    reader.onLoadEnd.listen((event) async {
      final bytes = reader.result as List<int>;
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];

      showDialog(
        context: context,
        builder: (context) => Center(
          child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.secondaryColor, size: 200),
        ),
      );

      // Check if the expected columns are present in the Excel file
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
      final headerRow = sheet!.rows.first
          .map((cell) => cell!.value.toString().trim())
          .toList();

      if (!headerRow.every((cell) => expectedColumns.contains(cell))) {
        Navigator.pop(context);
        double screenWidth = MediaQuery.of(context).size.width;
        GFToast.showToast(
            "Le fichier Excel ne contient pas les colonnes attendues.", context,
            trailing: const Icon(Icons.close),
            toastPosition: screenWidth > 1200
                ? GFToastPosition.TOP_RIGHT
                : GFToastPosition.TOP,
            backgroundColor: AppColors.redColor);
      } else {
        FirebaseApp firebaseApp = await Firebase.initializeApp(
            name: 'Secondary', options: Firebase.app().options);
        for (var i = 1; i < sheet.rows.length; i++) {
          try {
            final row = sheet.rows[i];
            final filiereName = row[6]!.value.toString();

            http.Response response = await http.get(
              Uri.parse(
                  '$BACKEND_URL/api/filiere/getFiliereByName/$filiereName'),
            );

            List<dynamic> filiere = jsonDecode(response.body);
            String idFiliere = filiere[0]['idFiliere'].toString();

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
              statut: true,
            );

            await addStudentTookFromExcel(etudiant, context, firebaseApp);
            totalAjoute++;
            // print(                "Matricule: ${etudiant.matricule} Nom: ${etudiant.nom} Prénom: ${etudiant.prenom} Email: ${etudiant.email} Password: ${etudiant.password}  Phone: ${etudiant.phone}  ID Filière: ${etudiant.idFiliere} Filière: ${etudiant.filiere} Niveau: ${etudiant.niveau} Statut: ${etudiant.statut}   ");
          } catch (e) {
            totalErreur++;
            // print('An error occurred while adding from Excel: $e');
          }
        }

        if (totalErreur > 0) {
          Navigator.pop(context);
          Helper().show_custom_message(
              'L\'opération s\'est déroulée avec $totalErreur erreurs. \n $totalAjoute étudiants ajouté(s) ',
              220,
              context);
        } else {
          Navigator.pop(context);
          Helper().succesMessage(context);
        }
      }
    });

    reader.readAsArrayBuffer(fileBlob);
  }

//HELPER
  Future addUserDetails(String nom, String prenom, String email, String phone,
      final ref, String? statut) async {
    await ref.set({
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
      'statut': statut ?? "1"
    });
  }

  //log out user method
  void logUserOut(BuildContext context) async {
    FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();

    prefs.setBool("loggedIn", false);
    prefs.remove("role");
    prefs.remove("email");
    prefs.remove("mdp");
    prefs.remove("user");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false);
  }
}
