import 'package:cloud_firestore/cloud_firestore.dart';

class Prof {
  String? idDoc;
  String nom;
  String prenom;
  String email;
  String phone;
  String statut;

  Prof({
    this.idDoc,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
    required this.statut,
  });

  factory Prof.fromDocument(DocumentSnapshot doc) {
    return Prof(
      idDoc: doc.id,
      nom: doc["nom"],
      prenom: doc["prenom"],
      email: doc["email"],
      phone: doc["phone"],
      statut: doc['statut'],
    );
  }
}
