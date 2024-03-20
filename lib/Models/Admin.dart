import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  String nom;
  String prenom;
  String email;
  String phone;

  Admin({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
  });

  factory Admin.fromDocument(DocumentSnapshot doc) {
    return Admin(
      nom: doc["nom"],
      prenom: doc["prenom"],
      email: doc["email"],
      phone: doc["phone"],
    );
  }
}
