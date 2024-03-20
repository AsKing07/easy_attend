import 'package:cloud_firestore/cloud_firestore.dart';

class Requete {
  String idRequete;
  String typeRequete;
  String details;
  String status;
  Object auteur;
  Timestamp dateCreation;

  Requete(
      {required this.idRequete,
      required this.typeRequete,
      required this.details,
      required this.status,
      required this.auteur,
      required this.dateCreation});

  factory Requete.fromDocument(DocumentSnapshot doc) {
    return Requete(
      idRequete: doc['idRequete'],
      typeRequete: doc["typeRequete"],
      details: doc["detail"],
      status: doc["status"],
      auteur: doc['auteur'],
      dateCreation: doc['dateCreation'],
    );
  }
}
