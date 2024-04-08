// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';

class get_Data {
  //METHODES

  //METHODES DES FILIERES
  Future getFiliereData() async {
    var data = await FirebaseFirestore.instance.collection("filiere").get();

    return data.docs;
  }

  Future getActifFiliereData() async {
    var data = await FirebaseFirestore.instance
        .collection("filiere")
        .where('statut', isEqualTo: "1")
        .get();
    return data.docs;
  }

  Future getFiliereById(id, BuildContext context) async {
    try {
      DocumentSnapshot x =
          await FirebaseFirestore.instance.collection('filiere').doc(id).get();
      return x;
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

  Future<DocumentSnapshot<Object?>> loadCurrentAdminData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final DocumentSnapshot x =
        await FirebaseFirestore.instance.collection("admin").doc(uid).get();
    // print(uid);

    return x;
  }

  //METHODES DES ETUDIANTS

  Future<DocumentSnapshot<Object?>> loadCurrentStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final DocumentSnapshot x =
        await FirebaseFirestore.instance.collection("etudiant").doc(uid).get();
    // print(uid);

    return x;
  }

  Future getActifStudentData() async {
    var data = await FirebaseFirestore.instance
        .collection("etudiant")
        .where("statut", isEqualTo: "1")
        .get();
    return data.docs;
  }

  Future getStudentData() async {
    var data = await FirebaseFirestore.instance.collection("etudiant").get();
    return data.docs;
  }

  Future getStudentById(id, BuildContext context) async {
    try {
      DocumentSnapshot x =
          await FirebaseFirestore.instance.collection('etudiant').doc(id).get();
      return x;
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

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
    // print(idFiliere);
    var data = await FirebaseFirestore.instance
        .collection("etudiant")
        .where('idFiliere', isEqualTo: idFiliere)
        .where('niveau', isEqualTo: niveau.toUpperCase())
        .where('statut', isEqualTo: '1')
        .get();
    return data.docs;
  }

  // METHODES DES PROFS

  Future<DocumentSnapshot<Object?>> loadCurrentProfData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final DocumentSnapshot x =
        await FirebaseFirestore.instance.collection("prof").doc(uid).get();
    // print(uid);

    return x;
  }

  Future getTeacherData() async {
    var data = await FirebaseFirestore.instance.collection("prof").get();
    return data.docs;
  }

  Future getProfById(id, BuildContext context) async {
    try {
      DocumentSnapshot x =
          await FirebaseFirestore.instance.collection('prof').doc(id).get();
      return x;
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
    var data = await FirebaseFirestore.instance
        .collection("prof")
        .where('statut', isEqualTo: "1")
        .get();
    return data.docs;
  }

//METHODES DES COURS

//Recupérer tous les cours
  Future getCourseData() async {
    var data = await FirebaseFirestore.instance.collection("cours").get();
    return data.docs;
  }

  //Récupérer un cours donné

  Future getCourseById(id, BuildContext context) async {
    try {
      DocumentSnapshot x =
          await FirebaseFirestore.instance.collection('cours').doc(id).get();
      return x;
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  // METHODES REQUETES
  Future getUnsolvedQueriesData() async {
    var data = await FirebaseFirestore.instance
        .collection("requete")
        .where("statut", isEqualTo: "2")
        .get();
    return data.docs;
  }

  Future getQueryById(id) async {
    DocumentSnapshot query =
        await FirebaseFirestore.instance.collection('requete').doc(id).get();
    return query;
  }

  // METHODES SEANCES

//Liste des séances d'un cours
  Future getSeanceOfOneCourse(String courseId) async {
    var data = await FirebaseFirestore.instance
        .collection("seance")
        .where("idCours", isEqualTo: courseId)
        .get();
    return data.docs;
  }

  //Récuperer une séance

  Future getSeanceById(id, BuildContext context) async {
    try {
      DocumentSnapshot x =
          await FirebaseFirestore.instance.collection('seance').doc(id).get();
      return x;
    } catch (e) {
      GFToast.showToast(
          "Une erreur est subvenue lors de la récupération des données",
          context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 6);
    }
  }

  Future getSeanceData(String seanceId) async {
    var doc = await FirebaseFirestore.instance
        .collection('seance')
        .doc(seanceId)
        .get();

    return doc;
  }
}
