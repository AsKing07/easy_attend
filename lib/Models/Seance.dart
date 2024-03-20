import 'package:cloud_firestore/cloud_firestore.dart';

class Seance {
  String idSeance;
  String idCours;
  Timestamp dateSeance;
  List<Object> presenceEtudiant = [];

  Seance({
    required this.idSeance,
    required this.idCours,
    required this.dateSeance,
    required this.presenceEtudiant,
  });

  factory Seance.fromDocument(DocumentSnapshot doc) {
    return Seance(
      idSeance: doc['idSeance'],
      idCours: doc["idCours"],
      dateSeance: doc["dateSeance"],
      presenceEtudiant: doc['presenceEtudiant'],
    );
  }
}
