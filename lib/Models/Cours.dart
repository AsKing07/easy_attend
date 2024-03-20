import 'package:cloud_firestore/cloud_firestore.dart';

class Cours {
  String idCours;
  String nomCours;
  String departementId;
  String filiereId;
  String niveau;
  String professeurId;

  Cours({
    required this.idCours,
    required this.nomCours,
    required this.departementId,
    required this.filiereId,
    required this.niveau,
    required this.professeurId,
  });

  factory Cours.fromDocument(DocumentSnapshot doc) {
    return Cours(
      idCours: doc['idCours'],
      nomCours: doc["nomCours"],
      filiereId: doc["filiereId"],
      departementId: doc["departementId"],
      niveau: doc['niveau'],
      professeurId: doc["professeurId"],
    );
  }
}
