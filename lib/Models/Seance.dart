// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Seance {
  String? idSeance;
  String idCours;
  Timestamp dateSeance;
  String seanceCode;
  List<Object>? presenceEtudiant = [];
  bool isActive;

  Seance(
      {this.idSeance,
      required this.idCours,
      required this.dateSeance,
      required this.seanceCode,
      this.presenceEtudiant,
      required this.isActive});

  factory Seance.fromDocument(DocumentSnapshot doc) {
    return Seance(
        idSeance: doc['idSeance'],
        idCours: doc["idCours"],
        dateSeance: doc["dateSeance"],
        presenceEtudiant: doc['presenceEtudiant'],
        isActive: doc['isActive'],
        seanceCode: doc['seanceCode']);
  }
}
