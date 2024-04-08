// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Departement {
  String idDept;
  String nomDept;
  List<String> filieres = [];

  Departement({
    required this.idDept,
    required this.nomDept,
    required this.filieres,
  });

  factory Departement.fromDocument(DocumentSnapshot doc) {
    return Departement(
      idDept: doc['idDept'],
      nomDept: doc["nomDept"],
      filieres: doc["filieres"],
    );
  }
}
