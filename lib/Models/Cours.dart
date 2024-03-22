import 'package:cloud_firestore/cloud_firestore.dart';

class Cours {
  String idCours;
  String nomCours;
  String? filiereId;
  String niveau;
  String? professeurId;

  Cours({
    required this.idCours,
    required this.nomCours,
    this.filiereId,
    required this.niveau,
    required this.professeurId,
  });

  factory Cours.fromDocument(DocumentSnapshot doc) {
    return Cours(
      idCours: doc['idCours'],
      nomCours: doc["nomCours"],
      filiereId: doc["filiereId"],
      niveau: doc['niveau'],
      professeurId: doc["professeurId"],
    );
  }
}
