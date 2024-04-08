// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Etudiant {
  String? uid;
  String nom;
  String prenom;
  String? email;
  String? password;
  String phone;
  String matricule;
  String? idFiliere;
  String filiere;
  String niveau;
  String statut;

  Etudiant({
    this.uid,
    required this.matricule,
    required this.nom,
    required this.prenom,
    this.email,
    this.password,
    required this.phone,
    required this.idFiliere,
    required this.filiere,
    required this.niveau,
    required this.statut,
  });

  factory Etudiant.fromDocument(DocumentSnapshot doc) {
    return Etudiant(
        uid: doc.id,
        matricule: doc['matricule'],
        nom: doc["nom"],
        prenom: doc["prenom"],
        email: doc["email"],
        password: doc["password"],
        phone: doc["phone"],
        idFiliere: doc["idFiliere"],
        filiere: doc["filiere"],
        niveau: doc["niveau"],
        statut: doc['statut']);
  }
}
