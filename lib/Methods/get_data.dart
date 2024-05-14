// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class get_Data {
  final BACKEND_URL = dotenv.env['API_URL'];

  //METHODES

  //METHODES DES FILIERES
  Future getFiliereData() async {
    var data = await FirebaseFirestore.instance.collection("filiere").get();

    return data.docs;
  }

  Future getActifFiliereData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getActifFiliereData'),
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
  // Future getActifFiliereData() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("filiere")
  //       .where('statut', isEqualTo: "1")
  //       .get();
  //   return data.docs;
  // }

  Future getFiliereById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/global/getFiliereById/$id'),
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
  // Future getFiliereById(id, BuildContext context) async {
  //   try {
  //     DocumentSnapshot x =
  //         await FirebaseFirestore.instance.collection('filiere').doc(id).get();
  //     return x;
  //   } catch (e) {
  //     GFToast.showToast(
  //         "Une erreur est subvenue lors de la récupération des données",
  //         context,
  //         backgroundColor: Colors.white,
  //         textStyle: const TextStyle(color: Colors.red),
  //         toastDuration: 6);
  //   }
  // }

  //METHODES DES ADMINS

  // Future<DocumentSnapshot<Object?>> loadCurrentAdminData() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   final DocumentSnapshot x =
  //       await FirebaseFirestore.instance.collection("admin").doc(uid).get();
  //   // print(uid);
  //   return x;
  // }

  Future loadCurrentAdminData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Envoi d'une requête GET à l'API
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/admin/$uid'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici
        Map<String, dynamic> admin = jsonDecode(response.body);
        // Utiliser les données de l'administrateur ici
        // print(admin);
        return admin;
      } else {
        // La requête a échoué, gérer l'erreur ici
        print(
            'Erreur lors de la récupération des données de l\'administrateur');
      }
    } catch (e) {
      // Gérer l'erreur d'envoi de la requête ici
      print('Erreur lors de l\'envoi de la requête');
    }
  }

  //METHODES DES ETUDIANTS

  Future loadCurrentStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getStudentById/$uid'),
    );

    Map<String, dynamic> x = jsonDecode(response.body);
    // print(uid);

    return x;
  }

  // Future<DocumentSnapshot<Object?>> loadCurrentStudentData() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   final DocumentSnapshot x =
  //       await FirebaseFirestore.instance.collection("etudiant").doc(uid).get();
  //   // print(uid);
  //   return x;
  // }

  Future getActifStudentData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getActifStudentData'),
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
  // Future getActifStudentData() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("etudiant")
  //       .where("statut", isEqualTo: "1")
  //       .get();
  //   return data.docs;
  // }

  Future getStudentData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getStudentData'),
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
  // Future getStudentData() async {
  //   var data = await FirebaseFirestore.instance.collection("etudiant").get();
  //   return data.docs;
  // }

  Future getStudentById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/global/getStudentById/${id}'),
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
  // Future getStudentById(id, BuildContext context) async {
  //   try {
  //     DocumentSnapshot x =
  //         await FirebaseFirestore.instance.collection('etudiant').doc(id).get();
  //     return x;
  //   } catch (e) {
  //     GFToast.showToast(
  //         "Une erreur est subvenue lors de la récupération des données",
  //         context,
  //         backgroundColor: Colors.white,
  //         textStyle: const TextStyle(color: Colors.red),
  //         toastDuration: 6);
  //   }
  // }

  Future getEtudiantsOfAFiliere(String idFiliere) async {
    // print(idFiliere);
    var data = await FirebaseFirestore.instance
        .collection("etudiant")
        .where('idFiliere', isEqualTo: idFiliere)
        .where('statut', isEqualTo: '1')
        .get();
    return data.docs;
  }

  Future getEtudiantsOfAFiliereAndNiveau(
      String idFiliere, String niveau) async {
    http.Response response = await http.get(Uri.parse(
        '$BACKEND_URL/api/global/getStudentData?idFiliere=${idFiliere}&niveau=$niveau'));

    List<dynamic> etudiants = jsonDecode(response.body);
    return etudiants;
  }
  // Future getEtudiantsOfAFiliereAndNiveau(
  //     String idFiliere, String niveau) async {
  //   // print(idFiliere);
  //   var data = await FirebaseFirestore.instance
  //       .collection("etudiant")
  //       .where('idFiliere', isEqualTo: idFiliere)
  //       .where('niveau', isEqualTo: niveau.toUpperCase())
  //       .where('statut', isEqualTo: '1')
  //       .get();
  //   return data.docs;
  // }

  // METHODES DES PROFS

  Future loadCurrentProfData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getProfById/$uid'),
    );

    Map<String, dynamic> x = jsonDecode(response.body);

    return x;
  }
  // Future<DocumentSnapshot<Object?>> loadCurrentProfData() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   final DocumentSnapshot x =
  //       await FirebaseFirestore.instance.collection("prof").doc(uid).get();
  //   // print(uid);
  //   return x;
  // }

  Future getTeacherData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getProfData/'),
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
        Uri.parse('$BACKEND_URL/api/global/getProfById/$id'),
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
  // Future getProfById(id, BuildContext context) async {
  //   try {
  //     DocumentSnapshot x =
  //         await FirebaseFirestore.instance.collection('prof').doc(id).get();
  //     return x;
  //   } catch (e) {
  //     GFToast.showToast(
  //         "Une erreur est subvenue lors de la récupération des données",
  //         context,
  //         backgroundColor: Colors.white,
  //         textStyle: const TextStyle(color: Colors.red),
  //         toastDuration: 6);
  //   }
  // }

  Future getActifTeacherData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getActifProfData'),
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
  // Future getActifTeacherData() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("prof")
  //       .where('statut', isEqualTo: "1")
  //       .get();
  //   return data.docs;
  // }

//METHODES DES COURS

//Recupérer tous les cours
  Future getCourseData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getActifCoursesData'),
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
  // Future getCourseData() async {
  //   var data = await FirebaseFirestore.instance.collection("cours").get();
  //   return data.docs;
  // }

  //Récupérer un cours donné

  Future getCourseById(id, BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/global/getCourseById/$id'),
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

  // Future getCourseById(id, BuildContext context) async {
  //   try {
  //     DocumentSnapshot x =
  //         await FirebaseFirestore.instance.collection('cours').doc(id).get();
  //     return x;
  //   } catch (e) {
  //     GFToast.showToast(
  //         "Une erreur est subvenue lors de la récupération des données",
  //         context,
  //         backgroundColor: Colors.white,
  //         textStyle: const TextStyle(color: Colors.red),
  //         toastDuration: 6);
  //   }
  // }

  // METHODES REQUETES
  Future getUnsolvedQueriesData() async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getUnsolvedRequestData'),
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
  // Future getUnsolvedQueriesData() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("requete")
  //       .where("statut", isEqualTo: "2")
  //       .get();
  //   return data.docs;
  // }

  Future getQueryById(id, BuildContext context) async {
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/global/getRequestById/$id'),
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
  // Future getQueryById(id) async {
  //   DocumentSnapshot query =
  //       await FirebaseFirestore.instance.collection('requete').doc(id).get();
  //   return query;
  // }

  // METHODES SEANCES

//Liste des séances d'un cours
  Future getSeanceOfOneCourse(String courseId) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/teacher/getSeanceData?idCours=$courseId'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        return seances;
      } else {
        throw Exception('Erreur lors de la récupération des seances');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }
  // Future getSeanceOfOneCourse(String courseId) async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("seance")
  //       .where("idCours", isEqualTo: courseId)
  //       .get();
  //   return data.docs;
  // }

  //Récuperer une séance

  // Future getSeanceById(id, BuildContext context) async {
  //   try {
  //     DocumentSnapshot x =
  //         await FirebaseFirestore.instance.collection('seance').doc(id).get();
  //     return x;
  //   } catch (e) {
  //     GFToast.showToast(
  //         "Une erreur est subvenue lors de la récupération des données",
  //         context,
  //         backgroundColor: Colors.white,
  //         textStyle: const TextStyle(color: Colors.red),
  //         toastDuration: 6);
  //   }
  // }

  // Future getSeanceData(String seanceId) async {
  //   var doc = await FirebaseFirestore.instance
  //       .collection('seance')
  //       .doc(seanceId)
  //       .get();

  //   return doc;
  // }
}
