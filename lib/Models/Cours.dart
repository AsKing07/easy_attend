// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Cours {
  String? idDoc;
  String idCours;
  String nomCours;
  String? filiereId;
  String niveau;
  String? professeurId;

  Cours({
    this.idDoc,
    required this.idCours,
    required this.nomCours,
    this.filiereId,
    required this.niveau,
    required this.professeurId,
  });

  factory Cours.fromDocument(DocumentSnapshot doc) {
    return Cours(
      idDoc: doc.id,
      idCours: doc['idCours'],
      nomCours: doc["nomCours"],
      filiereId: doc["filiereId"],
      niveau: doc['niveau'],
      professeurId: doc["professeurId"],
    );
  }
}
