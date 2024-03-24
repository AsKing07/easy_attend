// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Models/Cours.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/material.dart';

class set_Data {
//METHODES DES FILIERES

  //Ajouter Filière
  Future<void> ajouterFiliere(
      String nom, String id, List<String> niveaux, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    final docSnapshot = await FirebaseFirestore.instance
        .collection('filiere')
        .doc(id.toUpperCase())
        .get();

    if (docSnapshot.exists) {
      // La filière existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().filiereExistanteMessage(context);
    } else {
      // La filière n'existe pas encore, ajouter la nouvelle filière
      await FirebaseFirestore.instance.collection('filiere').add({
        'nomFiliere': nom.toUpperCase(),
        'idFiliere': id.toUpperCase(),
        'niveaux': niveaux,
        'statut': "1",
      }).then((value) {
        // Filère ajoutée avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      }).catchError((error) {
        // Une erreur s'est produite lors de l'ajout de la filière
        print(error);
        Navigator.pop(context);
        Helper().ErrorMessage(context);
      });
    }
  }

  //Modifier Filière
  void modifierFiliere(
      filiereId, nomFiliere, idFiliere, niveaux, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    FirebaseFirestore.instance.collection('filiere').doc(filiereId).update({
      'nomFiliere': nomFiliere,
      'idFiliere': idFiliere,
      'niveaux': niveaux,
    }).then((value) {
      // Filière modifiée avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    }).catchError((error) {
      // Une erreur s'est produite lors de la modification de la filière
      print(error);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    });
  }

  //Supprimer filière
  Future<void> deleteFiliere(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Supprimez la filière de Firestore

    try {
      FirebaseFirestore.instance
          .collection('filiere')
          .doc(id)
          .update({'statut': "0"});
      //TODO: Supprimer les cours associés
      //
      //TODO Supprimer les  étudiants associé
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //Restaurer filière
  Future<void> restoreFiliere(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Restaurer la filière de Firestore

    try {
      FirebaseFirestore.instance
          .collection('filiere')
          .doc(id)
          .update({'statut': "1"});
      //TODO: Restaurer les cours associés
      //
      //TODO Restaurer les  étudiants associé
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //Supprimer toutes les filières
  Future<void> deleteAllFiliere(BuildContext context) async {
    try {
      showDialog(
          context: context,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("filiere").get();

      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'statut': "0"});
        //TODO: Supprimer les cours associés
        //
        //TODO Supprimer les  étudiants associé
      });
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//METHODES DES PROFS

//Supprimer prof
  Future<void> deleteProf(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Update le statut du prof dans Firestore

    try {
      FirebaseFirestore.instance
          .collection('prof')
          .doc(id)
          .update({"statut": "0"});

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //Restaurer prof
  Future<void> restoreProf(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Update le statut du prof dans Firestore

    try {
      FirebaseFirestore.instance
          .collection('prof')
          .doc(id)
          .update({"statut": "1"});

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//Modifier prof
  void modifierProfByAdmin(profId, nom, prenom, phone, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    FirebaseFirestore.instance.collection('prof').doc(profId).update({
      'nom': nom.toString().toUpperCase(),
      'phone': phone.toString().toUpperCase(),
      'prenom': prenom.toString().toUpperCase(),
    }).then((value) {
      // Filière modifiée avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    }).catchError((error) {
      // Une erreur s'est produite lors de la modification de la filière
      print(error);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    });
  }

//METHODES DES COURS

//Ajouter cours
  Future<void> ajouterCours(Cours cours, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    final docSnapshot = await FirebaseFirestore.instance
        .collection('cours')
        .where('idCours', isEqualTo: cours.idCours)
        .get();

    if (docSnapshot.docs.length > 0) {
      // Le cours existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    } else {
      // Le cours n'existe pas encore, ajouter
      await FirebaseFirestore.instance.collection('cours').add({
        'nomCours': cours.nomCours.toUpperCase(),
        'idCours': cours.idCours.toUpperCase(),
        'niveau': cours.niveau.toUpperCase(),
        'filiereId': cours.filiereId,
        'professeurId': cours.professeurId,
      }).then((value) {
        // Cours ajouté avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      }).catchError((error) {
        // Une erreur s'est produite lors de l'ajout du cours
        print(error);
        Navigator.pop(context);
        Helper().ErrorMessage(context);
      });
    }
  }

//Modifier cours
  Future<void> modifierCours(Cours cours, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    await FirebaseFirestore.instance
        .collection('cours')
        .doc(cours.idDoc)
        .update({
      'nomCours': cours.nomCours,
      'idCours': cours.idCours.toUpperCase(),
      'niveau': cours.niveau.toUpperCase(),
      'filiereId': cours.filiereId,
      'professeurId': cours.professeurId
    }).then((value) {
      // Cours modifié avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    }).catchError((error) {
      // Une erreur s'est produite lors de la modification du cours
      print(error);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    });
  }

// SUPPRIMER COURS
  Future<void> deleteCours(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Supprimez le cours de Firestore

    try {
      FirebaseFirestore.instance.collection('cours').doc(id).delete();

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

// SUPPRIMER TOUS LES COURS
  Future<void> deleteAllCours(
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Supprimez les cours de Firestore

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("cours").get();

      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//METHODES DES ETUDIANTS

//Delete Student
  Future<void> deleteOneStudent(id, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Update le statut de l'étudiant dans  Firestore

    try {
      FirebaseFirestore.instance
          .collection('etudiant')
          .doc(id)
          .update({"statut": "0"});

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//Restore Student
  Future<void> restoreOneStudent(id, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // Update le statut de l'étudiant dans  Firestore

    try {
      FirebaseFirestore.instance
          .collection('etudiant')
          .doc(id)
          .update({"statut": "1"});

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
}
