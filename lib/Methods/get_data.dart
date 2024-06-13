// ignore_for_file: use_build_context_synchronously, camel_case_types, non_constant_identifier_names

import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class get_Data {
  final BACKEND_URL = dotenv.env['API_URL'];

  //METHODES

  //METHODES DES FILIERES
  // Future getFiliereData() async {
  //   var data = await FirebaseFirestore.instance.collection("filiere").get();
  //   return data.docs;
  // }

  Future getActifFiliereData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/filiere/getActifFiliereData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> filieres = jsonDecode(response.body);
      // Utiliser les données des filieres ici
      // print(response.body);
      //print(filieres.length);
      return filieres;
    } else {
      // La requête a échoué, gérer l'erreur ici
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Impossible de récupérer les filières actives. Veuillez réessayer.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getFiliereById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/filiere/getFiliereById/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici
        dynamic filiere = jsonDecode(response.body);
        // Utiliser les données des filieres ici
        //  print(response.body);
        //print(filiere[0]);
        return filiere[0];
      } else {
        // La requête a échoué, gérer l'erreur ici
        GFToast.showToast(
            "Une erreur est subvenue lors de la récupération des données.",
            context,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.red),
            toastDuration: 6);
      }
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données. Erreur:$e",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  //METHODES DES ADMINS

  Future loadCurrentAdminData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var utilisateur = json.decode(prefs.getString('user')!);
    Map<String, dynamic> admin = utilisateur;
    return admin;
    // try {
    //   final SharedPreferences prefs = await SharedPreferences.getInstance();
    //   var utilisateur = json.decode(prefs.getString('user')!);
    //   // final uid = FirebaseAuth.instance.currentUser?.uid;
    //   final uid = utilisateur['uid'];

    //   // Envoi d'une requête GET à l'API
    //   http.Response response = await http.get(
    //     Uri.parse('$BACKEND_URL/api/admin/$uid'),
    //   );

    //   if (response.statusCode == 200) {
    //     // La requête a réussi, traiter la réponse ici
    //     Map<String, dynamic> admin = jsonDecode(response.body);
    //     // Utiliser les données de l'administrateur ici
    //     // print(admin);
    //     return admin;
    //   } else {
    //     // La requête a échoué, gérer l'erreur ici
    //     print(
    //         'Erreur lors de la récupération des données de l\'administrateur');
    //     return {'nom': 'Administrateur', 'prenom': 'Administrateur'};
    //   }
    // } catch (e) {
    //   // Gérer l'erreur d'envoi de la requête ici
    //   print('Erreur lors de l\'envoi de la requête');
    //}
  }

  //METHODES DES ETUDIANTS

  Future loadCurrentStudentData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var utilisateur = json.decode(prefs.getString('user')!);
    //   // final uid = FirebaseAuth.instance.currentUser?.uid;
    //   final uid = utilisateur['uid'];
    // http.Response response = await http.get(
    //   Uri.parse('$BACKEND_URL/api/student/getStudentById/$uid'),
    // );

    // Map<String, dynamic> x = jsonDecode(response.body);
    // // print(uid);

    Map<String, dynamic> x = utilisateur;
    return x;
  }

  Future getActifStudentData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/student/getActifStudentData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> students = jsonDecode(response.body);
      // Utiliser les données des étudiabts ici
      //   print(response.body);
      // print(students.length);
      return students;
    } else {
      // La requête a échoué, gérer l'erreur ici

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer les étudiants.'),
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getStudentData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/student/getStudentData'),
    );
    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> students = jsonDecode(response.body);
      // Utiliser les données des filieres ici
      return students;
    } else {
      // La requête a échoué, gérer l'erreur ici
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données.",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  Future getStudentById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/student/getStudentById/$id'),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> student = jsonDecode(response.body);
        return student;
      }
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  Future getEtudiantsOfAFiliereAndNiveau(
      String idFiliere, String niveau) async {
    http.Response response = await http.get(Uri.parse(
        '$BACKEND_URL/api/student/getStudentData?idFiliere=$idFiliere&niveau=$niveau'));

    List<dynamic> etudiants = jsonDecode(response.body);
    return etudiants;
  }

  // METHODES DES PROFS

  Future loadCurrentProfData() async {
    // final uid = FirebaseAuth.instance.currentUser?.uid;

    // http.Response response = await http.get(
    //   Uri.parse('$BACKEND_URL/api/prof/getProfById/$uid'),
    // );

    // Map<String, dynamic> x = jsonDecode(response.body);

    // return x;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var utilisateur = json.decode(prefs.getString('user')!);
    Map<String, dynamic> prof = utilisateur;
    return prof;
  }

  Future getTeacherData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/prof/getProfData/'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> profs = jsonDecode(response.body);
      // Utiliser les données des filieres ici
      //   print(response.body);
      //   print(profs.length);
      return profs;
    } else {
      // La requête a échoué, gérer l'erreur ici
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des professeurs",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }

    // var data = await FirebaseFirestore.instance.collection("prof").get();
    // return data.docs;
  }

  Future getProfById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/prof/getProfById/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici
        dynamic prof = jsonDecode(response.body);
        // Utiliser les données des profs ici
        return prof;
      } else {
        // La requête a échoué, gérer l'erreur ici
        GFToast.showToast(
            "Une erreur est subvenue lors de la récupération des données",
            context,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.red),
            toastDuration: 6);
        // print(response.body);
      }
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  Future getActifTeacherData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/prof/getActifProfData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> profs = jsonDecode(response.body);
      // Utiliser les données des profs ici
      return profs;
    } else {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

//METHODES DES COURS

//Recupérer tous les cours
  Future getCourseData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/cours/getActifCoursesData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> cours = jsonDecode(response.body);
      // Utiliser les données des cours ici
      return cours;
    } else {
      // La requête a échoué, gérer l'erreur ici
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  //Récupérer un cours donné

  Future getCourseById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/cours/getCourseById/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici
        dynamic course = jsonDecode(response.body);
        // Utiliser les données des filieres ici

        return course[0];
      } else {
        // La requête a échoué, gérer l'erreur ici
        GFToast.showToast(
            "Une erreur est subvenue lors de la récupération des données",
            context,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.red),
            toastDuration: 6);
      }
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données. Erreur: $e",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  // METHODES REQUETES
  Future getUnsolvedQueriesData(BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/requete/getUnsolvedRequestData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> queries = jsonDecode(response.body);

      return queries;
    } else {
      // La requête a échoué, gérer l'erreur ici
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer les requêtes.'),
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getQueryById(id, BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/requete/$id'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      dynamic requete = jsonDecode(response.body);
      // Utiliser les données des filieres ici

      return requete;
    } else {
      // La requête a échoué, gérer l'erreur ici
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  // METHODES SEANCES

//Liste des séances d'un cours
  Future getSeanceOfOneCourse(String courseId, BuildContext context) async {
    http.Response response;
    try {
      response = await http.get(
          Uri.parse('$BACKEND_URL/api/seance/getSeanceData?idCours=$courseId'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        return seances;
      } else {
        throw Exception('Erreur lors de la récupération des seances');
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Impossible de récupérer les séances de ce cours. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getSeanceByCode(String code, BuildContext context) async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$BACKEND_URL/api/seance/getSeanceByCode/$code'));

      if (response.statusCode == 200) {
        dynamic seance = jsonDecode(response.body);
        return seance;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer la séance.'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer la séance. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
