// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Filiere {
  String idFiliere;
  String nomFiliere;
  String statut;
  String? idDoc;
  List<String> niveaux = [];

  Filiere({
    required this.nomFiliere,
    required this.idFiliere,
    required this.statut,
    required this.niveaux,
    this.idDoc,
  });

  factory Filiere.fromDocument(DocumentSnapshot doc) {
    return Filiere(
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["idFiliere"],
        statut: doc["statut"],
        niveaux: doc['niveau'],
        idDoc: doc.id);
  }
}
