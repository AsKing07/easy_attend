// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
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

  Future getActifFiliereData() async {
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
      print('Erreur lors de la récupération des filieres actives');
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
        print('Erreur lors de la récupération de la filière');
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

  Future getActifStudentData() async {
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
      print('Erreur lors de la récupération des étudiants actifs');
    }
  }

  Future getStudentData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/student/getStudentData'),
    );
    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> students = jsonDecode(response.body);
      // Utiliser les données des filieres ici
      print(response.body);
      print(students.length);
      return students;
    } else {
      // La requête a échoué, gérer l'erreur ici
      print('Erreur lors de la récupération des étudiants');
    }
  }

  Future getStudentById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/student/getStudentById/${id}'),
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
        '$BACKEND_URL/api/student/getStudentData?idFiliere=${idFiliere}&niveau=$niveau'));

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

  Future getTeacherData() async {
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
      print('Erreur lors de la récupération des filieres actives');
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
        print(response.body);
        print(prof);
        return prof;
      } else {
        // La requête a échoué, gérer l'erreur ici
        print('Erreur lors de la récupération du prof');
        print(response.body);
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

  Future getActifTeacherData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/prof/getActifProfData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> profs = jsonDecode(response.body);
      // Utiliser les données des profs ici
      //  print(response.body);
      // print(profs.length);
      return profs;
    } else {
      // La requête a échoué, gérer l'erreur ici
      print('Erreur lors de la récupération des profs actifs');
    }
  }

//METHODES DES COURS

//Recupérer tous les cours
  Future getCourseData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/cours/getActifCoursesData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> cours = jsonDecode(response.body);
      // Utiliser les données des cours ici
      print(response.body);
      print(cours.length);
      return cours;
    } else {
      // La requête a échoué, gérer l'erreur ici
      print('Erreur lors de la récupération des profs actifs');
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
        print(response.body);
        print(course);
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
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
      print(e);
    }
  }

  // METHODES REQUETES
  Future getUnsolvedQueriesData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/requete/getUnsolvedRequestData'),
    );

    if (response.statusCode == 200) {
      // La requête a réussi, traiter la réponse ici
      List<dynamic> queries = jsonDecode(response.body);

      return queries;
    } else {
      // La requête a échoué, gérer l'erreur ici
      print('Erreur lors de la récupération des requêtes inactives');
    }
  }

  Future getQueryById(id, BuildContext context) async {
    print(id);
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/requete/$id'),
    );
    print(response.body);

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
  Future getSeanceOfOneCourse(String courseId) async {
    http.Response response;
    try {
      response = await http.get(
          Uri.parse('$BACKEND_URL/api/seance/getSeanceData?idCours=$courseId'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        return seances;
      } else {
        print(response.body);
        throw Exception('Erreur lors de la récupération des seances');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }

  Future getSeanceByCode(String code) async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$BACKEND_URL/api/seance/getSeanceByCode/$code'));

      if (response.statusCode == 200) {
        dynamic seance = jsonDecode(response.body);
        return seance;
      } else {
        throw Exception('Erreur lors de la récupération de la seance');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }
}
