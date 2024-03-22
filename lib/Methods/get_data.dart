import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';

class get_dataAdmin {
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
      // ignore: use_build_context_synchronously
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
    print(x);
    return x;
  }

  //METHODES DES ETUDIANTS

  Future getStudentData() async {
    var data = await FirebaseFirestore.instance.collection("allStudent").get();
    return data.docs;
  }

  // METHODES DES PROFS

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
      // ignore: use_build_context_synchronously
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
  Future getCourseData() async {
    var data = await FirebaseFirestore.instance.collection("courses").get();
    return data.docs;
  }
}
