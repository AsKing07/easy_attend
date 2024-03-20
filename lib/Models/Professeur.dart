import 'package:cloud_firestore/cloud_firestore.dart';

class Prof {
  String nom;
  String prenom;
  String email;
  String phone;

  Prof({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
  });

  factory Prof.fromDocument(DocumentSnapshot doc) {
    return Prof(
      nom: doc["nom"],
      prenom: doc["prenom"],
      email: doc["email"],
      phone: doc["phone"],
    );
  }
}
