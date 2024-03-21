import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/my_success_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class set_data_Admin {
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
      filiereExistanteMessage(context);
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
        succesMessage(context);
      }).catchError((error) {
        // Une erreur s'est produite lors de l'ajout de la filière
        print(error);
        Navigator.pop(context);
        errorMessage(context);
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
      succesMessage(context);
    }).catchError((error) {
      // Une erreur s'est produite lors de la modification de la filière
      print(error);
      Navigator.pop(context);
      errorMessage(context);
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
      errorMessage(context);
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
    // Supprimez la filière de Firestore

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
      errorMessage(context);
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
      errorMessage(context);
    }
  }

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
    // Supprimez le prof de Firestore

    try {
      FirebaseFirestore.instance
          .collection('prof')
          .doc(id)
          .update({"statut": "0"});

      //TODO: Supprimer le prof des cours associés

      Navigator.pop(context);
    } catch (e) {
      errorMessage(context);
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
    // Supprimez le prof de Firestore

    try {
      FirebaseFirestore.instance
          .collection('prof')
          .doc(id)
          .update({"statut": "1"});

      Navigator.pop(context);
    } catch (e) {
      errorMessage(context);
    }
  }

//Modifier Filière
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
      succesMessage(context);
    }).catchError((error) {
      // Une erreur s'est produite lors de la modification de la filière
      print(error);
      Navigator.pop(context);
      errorMessage(context);
    });
  }

  void errorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Une erreur inconnue s'est produite.", height: 180);
      },
    );
  }

  void filiereExistanteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Une filière avec le même id existe déjà.", height: 160);
      },
    );
  }

  void succesMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessWidget(
            content: "L'opération a été un succes.", height: 100);
      },
    );
  }
}
