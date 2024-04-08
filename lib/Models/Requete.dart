// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Requete {
  String idRequete;
  String type;
  String details;
  String statut;
  String auteur;
  String idAuteur;
  Timestamp dateCreation;

  Requete(
      {required this.idRequete,
      required this.type,
      required this.details,
      required this.statut,
      required this.auteur,
      required this.idAuteur,
      required this.dateCreation});

  factory Requete.fromDocument(DocumentSnapshot doc) {
    return Requete(
      idRequete: doc['idRequete'],
      type: doc["type"],
      details: doc["details"],
      statut: doc["statut"],
      auteur: doc['auteur'],
      dateCreation: doc['dateCreation'],
      idAuteur: doc['idAuteur'],
    );
  }
}
