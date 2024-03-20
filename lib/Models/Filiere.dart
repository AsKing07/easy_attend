import 'package:cloud_firestore/cloud_firestore.dart';

class Filiere {
  String idFiliere;
  String nomFiliere;
  String statut;
  List<String> niveaux = [];

  Filiere({
    required this.nomFiliere,
    required this.idFiliere,
    required this.statut,
    required this.niveaux,
  });

  factory Filiere.fromDocument(DocumentSnapshot doc) {
    return Filiere(
      nomFiliere: doc["nomFiliere"],
      idFiliere: doc["idFiliere"],
      statut: doc["statut"],
      niveaux: doc['niveau'],
    );
  }
}
