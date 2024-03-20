import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  String uid;
  String nom;
  String prenom;
  String email;
  String password;
  String phone;
  String matricule;
  String idFiliere;

  Admin({
    required this.uid,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.phone,
    required this.idFiliere,
  });

  factory Admin.fromDocument(DocumentSnapshot doc) {
    return Admin(
      uid: doc['uid'],
      matricule: doc['matricule'],
      nom: doc["nom"],
      prenom: doc["prenom"],
      email: doc["email"],
      password: doc["password"],
      phone: doc["phone"],
      idFiliere: doc["idFiliere"],
    );
  }
}
