// ignore_for_file: use_build_context_synchronously, camel_case_types, unused_local_variable, non_constant_identifier_names

import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Cours.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfOneCourseSeance.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class set_Data {
  final BACKEND_URL = dotenv.env['API_URL'];
//METHODES DES FILIERES

  //Ajouter Filière
  Future<void> ajouterFiliere(
      String nom, String id, List<String> niveaux, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 300),
            ));

    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/filiere/getFiliereBySigle/$id'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // La filière existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().filiereExistanteMessage(context);
    } else {
      // La filière n'existe pas encore, ajouter la nouvelle filière
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/filiere/'),
        body: jsonEncode({
          'nomFiliere': nom.toUpperCase().trim(),
          'sigleFiliere': id.toUpperCase().trim(),
          'niveaux': niveaux,
          'statut': true
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Filère ajoutée avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      } else {
        // Une erreur s'est produite lors de l'ajout de la filière

        Navigator.pop(context);
        Helper().ErrorMessage(context);
      }
    }
  }

  //Modifier Filière
  void modifierFiliere(
      filiereId, nomFiliere, idFiliere, niveaux, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/filiere/'),
      body: jsonEncode({
        'nomFiliere': nomFiliere.toString().toUpperCase().trim(),
        'sigleFiliere': idFiliere.toString().toUpperCase().trim(),
        'niveaux': niveaux,
        'idFiliere': filiereId
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      // Filère modifiée avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    } else {
      // Une erreur s'est produite lors de la modification de la filière

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

  //Supprimer filière
  Future<void> deleteFiliere(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Supprimez la filière

    try {
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/filiere/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Supprimer les cours
        http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/cours/deleteCoursesByFiliere/$id'),
        );
        // Supprimer les  étudiants
        response = await http.delete(
          Uri.parse('$BACKEND_URL/api/student/deleteStudentsByFiliere/$id'),
        );
      } else {
        // La requête a échoué, gérer l'erreur ici
        GFToast.showToast(
            "Une erreur est subvenue lors de la suppression", context,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.red),
            toastDuration: 6);
      }

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
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Restaurer la filière

    try {
      http.Response response = await http.put(
        Uri.parse('$BACKEND_URL/api/filiere/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Restaurer les  étudiants
        response = await http.put(
          Uri.parse('$BACKEND_URL/api/student/restaureStudentsByFiliere/$id'),
        );

        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erreur lors de la restauration des etudiants de la filière'),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }

        response = await http.put(
          Uri.parse('$BACKEND_URL/api/cours/restaureCoursesByFiliere/$id'),
        );

        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erreur lors de la restauration des cours de la filière'),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // La requête a échoué, gérer l'erreur ici
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la restauration de la filière.'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }

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
          builder: (context) => Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              ));

      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/filiere/'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Supprimer les cours
        http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/cours/'),
        );
        // Supprimer les  étudiants
        response = await http.delete(
          Uri.parse('$BACKEND_URL/api/student/'),
        );
      } else {
        // La requête a échoué, gérer l'erreur ici
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression des données!'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Update le statut du prof

    try {
      http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/prof/$id'),
          headers: {'Content-Type': 'application/json'});
      Navigator.pop(context);
      if (response.statusCode != 200) {
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //Supprimer tous les prof
  Future<void> deleteAllProf(
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Update les statuts des profs

    try {
      http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/prof/'),
          headers: {'Content-Type': 'application/json'});

      Navigator.pop(context);
      if (response.statusCode != 200) {
        Helper().ErrorMessage(context);
      }
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
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Update le statut du prof dans Firestore

    try {
      http.Response response = await http.put(
        Uri.parse('$BACKEND_URL/api/prof/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        Navigator.pop(context);

        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Navigator.pop(context);

      Helper().ErrorMessage(context);
    }
  }

  Future<void> modifierProfByAdmin(
      profId, nom, prenom, phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/prof/'),
      body: jsonEncode({
        'nom': nom.toString().toUpperCase().trim(),
        'phone': phone.toString().toUpperCase().trim(),
        'prenom': prenom.toString().toUpperCase().trim(),
        'uid': profId
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Prof modifiée avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    } else {
      // Une erreur s'est produite lors de la modification de l'étudiant
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

//METHODES DES COURS

//Ajouter cours
  Future<void> ajouterCours(Cours cours, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/cours/getCourseBySigle/${cours.idCours}'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // Le cours existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().coursExistantMessage(context);
    } else {
      // Le cours n'existe pas encore, ajouter le
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/cours/'),
        body: jsonEncode({
          'nomCours': cours.nomCours.toUpperCase().trim(),
          'sigleCours': cours.idCours.trim(),
          'niveau': cours.niveau.toUpperCase().trim(),
          'idFiliere': cours.filiereId.toString().trim(),
          'idProfesseur': cours.professeurId!.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Cours ajouté avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      } else {
        // Une erreur s'est produite lors de l'ajout du cours

        Navigator.pop(context);
        Helper().ErrorMessage(context);
      }
    }
  }

//Modifier cours
  Future<void> modifierCours(Cours cours, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/cours/'),
      body: jsonEncode({
        'idCours': cours.idDoc,
        'nomCours': cours.nomCours.toUpperCase().trim(),
        'sigleCours': cours.idCours.trim(),
        'niveau': cours.niveau.toUpperCase().trim(),
        'idFiliere': cours.filiereId.toString().trim(),
        'idProfesseur': cours.professeurId!.trim(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Cours modifié avec succès
      Navigator.pop(context);
      Helper().succesMessage(context);
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

// SUPPRIMER COURS
  Future<void> deleteCours(
    id,
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    try {
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/cours/$id'),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        Helper().ErrorMessage(context);
      }
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
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Supprimez les cours de Firestore

    try {
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/admin/courses'),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//METHODES DES ETUDIANTS

  Future<void> modifierEtudiantByAdmin(idEtudiant, nom, prenom, phone, filiere,
      idFiliere, niveau, matricule, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.get(
      Uri.parse(
          '$BACKEND_URL/api/student/getStudentByMatricule?matricule=${matricule.toString().toUpperCase()}&id=$idEtudiant'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // L' étudiant existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return myErrorWidget(
              content: "Un étudiant avec le même matricule existe déjà.",
              height: 160);
        },
      );
    } else {
      http.Response response = await http.put(
        Uri.parse('$BACKEND_URL/api/student/'),
        body: jsonEncode({
          'nom': nom.toString().toUpperCase().trim(),
          'phone': phone.toString().toUpperCase().trim(),
          'prenom': prenom.toString().toUpperCase().trim(),
          'filiere': filiere.toString().toUpperCase().trim(),
          'idFiliere': idFiliere.toString().trim(),
          'niveau': niveau.toString().toUpperCase().trim(),
          'matricule': matricule.toString().toUpperCase().trim(),
          'uid': idEtudiant
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Etudiant modifiée avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      } else {
        // Une erreur s'est produite lors de la modification de l'étudiant

        Navigator.pop(context);
        Helper().ErrorMessage(context);
      }
    }
  }

//Delete Student
  Future<void> deleteOneStudent(id, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Update le statut de l'étudiant

    try {
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/student/$id'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //Delete All Students
  Future<void> deleteAllStudents(
    BuildContext context,
  ) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    try {
      // Supprimer les  étudiants
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/student/'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

//Restore Student
  Future<void> restoreOneStudent(id, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    // Update le statut de l'étudiant

    try {
      http.Response response = await http.put(
        Uri.parse('$BACKEND_URL/api/student/$id'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }

  //METHODES DES REQUETES

  //Approuver requete
  Future<void> approuverRequete(idRequete, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/requete/updateRequestStatus'),
      body: jsonEncode({
        'idRequete': idRequete,
        'action': "Approuver",
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      //succès
      Navigator.pop(context);
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

  //Désapprouver requete
  Future<void> desapprouverRequete(idRequete, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/requete/updateRequestStatus'),
      body: jsonEncode({
        'idRequete': idRequete,
        'action': "Refuser",
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //succès
      Navigator.pop(context);
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

  //Mettre requete en attente
  Future<void> mettreEnAttenteRequete(idRequete, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/requete/updateRequestStatus'),
      body: jsonEncode({
        'idRequete': idRequete,
        'action': "Attente",
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      //succès
      Navigator.pop(context);
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

  //CREER REQUETE

  Future<void> createQuery(auteur, idAuteur, type, sujet, details, statut,
      dateCreation, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    try {
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/requete/'),
        body: jsonEncode({
          "auteur": auteur,
          "idAuteur": idAuteur,
          "type": type,
          "sujet": sujet,
          "details": details,
          "statut": "2",
          "dateCreation": dateCreation.toIso8601String()
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Cours ajouté avec succès
        Navigator.pop(context);
        Helper().succesMessage(context);
      } else {
        // Une erreur s'est produite lors de l'ajout du cours

        Navigator.pop(context);
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().ErrorMessage(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

//METHODES DES SEANCES
//Mettre à jour présence
//todo
  Future updatePresenceEtudiant(String codeSeance, String etudiantId,
      bool present, BuildContext context) async {
    try {
      showDialog(
          context: context,
          builder: (context) => Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              ));

      // Récupérer le document existant
      dynamic seance = await get_Data().getSeanceByCode(codeSeance, context);

      // Vérifier si le document existe
      if (seance != null) {
        // Récupérer la liste des présences
        Map<String, dynamic>? presenceEtudiant =
            jsonDecode(seance['presenceEtudiant']);

        presenceEtudiant ??= {};

        // Rechercher l'étudiant dans la liste et mettre à jour sa présence
        // if (presenceEtudiant.containsKey(etudiantId)) {
        //   presenceEtudiant[etudiantId] = present;
        // }

        presenceEtudiant[etudiantId] = present;

        // Mettre à jour le document avec les nouvelles données
        http.Response response = await http.put(
          Uri.parse('$BACKEND_URL/api/seance/updateSeancePresence'),
          body: jsonEncode({
            'idSeance': seance['idSeance'],
            'presenceEtudiant': presenceEtudiant,
          }),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          return true;
        } else {
          // Une erreur s'est produite

          Navigator.pop(context);
          Helper().ErrorMessage(context);
          return false;
        }
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().ErrorMessage(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Future<void> updatePresenceEtudiant(String seanceId, String etudiantId,
  //     bool present, BuildContext context) async {
  //   try {
  //     showDialog(
  //         context: context,
  //         builder: (context) => Center(
  //               child: LoadingAnimationWidget.hexagonDots(
  //                   color: AppColors.secondaryColor, size: 100),
  //             ));
  //     // Récupérer le document existant
  //     DocumentSnapshot seanceSnapshot = await FirebaseFirestore.instance
  //         .collection('seance')
  //         .doc(seanceId)
  //         .get();
  //     // Vérifier si le document existe
  //     if (seanceSnapshot.exists) {
  //       // Récupérer la liste des présences
  //       Map<String, dynamic>? presenceEtudiant =
  //           seanceSnapshot.get('presenceEtudiant');
  //       presenceEtudiant ??= {};
  //       // Rechercher l'étudiant dans la liste et mettre à jour sa présence
  //       // if (presenceEtudiant.containsKey(etudiantId)) {
  //       //   presenceEtudiant[etudiantId] = present;
  //       // }
  //       presenceEtudiant[etudiantId] = present;
  //       // Mettre à jour le document Firebase avec les nouvelles données
  //       await FirebaseFirestore.instance
  //           .collection('seance')
  //           .doc(seanceId)
  //           .update({
  //         'presenceEtudiant': presenceEtudiant,
  //       });
  //       Navigator.pop(context);
  //     }
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

  Future createSeance(course, dateSeance, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    try {
      Map<String, bool> presenceEtudiantsMap = {};

      Map<String, dynamic> cours =
          await get_Data().getCourseById(course['idCours'], context);

      final List<dynamic> etudiantDoc = await get_Data()
          .getEtudiantsOfAFiliereAndNiveau(cours['idFiliere'], cours['niveau']);

      List<Etudiant> etudiants = [];

      for (var doc in etudiantDoc) {
        final etudiant = Etudiant(
            uid: doc['uid'],
            matricule: doc['matricule'],
            nom: doc['nom'],
            prenom: doc['prenom'],
            phone: doc['phone'],
            idFiliere: doc['idFiliere'],
            filiere: doc["filiere"],
            niveau: doc['niveau'],
            statut: doc['statut'] == 1);

        etudiants.add(etudiant);
      }

      List<Map<String, dynamic>> presenceEtudiant =
          List.generate(etudiants.length, (index) {
        return {'id': etudiants[index].uid, 'present': false};
      });

      for (int i = 0; i < etudiants.length; i++) {
        presenceEtudiantsMap[etudiants[i].uid!] =
            presenceEtudiant[i]['present'];
      }

      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/seance/'),
        body: jsonEncode({
          'idCours': course['idCours'].toString().trim(),
          'dateSeance': dateSeance.toIso8601String(),
          'presenceEtudiant': presenceEtudiantsMap,
          'isActive': false,
          'seanceCode': randomAlphaNumeric(6).toUpperCase(),
          'presenceTookOnce': false
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Séance ajouté avec succès

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListOfOneCourseSeancePage(
                    course: course,
                  )),
        );
      } else {
        // Une erreur s'est produite

        Navigator.pop(context);
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().ErrorMessage(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future updateSeancePresence(idSeance, presence, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 200),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/seance/updateSeancePresence'),
      body: jsonEncode({
        'idSeance': idSeance,
        'presenceEtudiant': presence,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondaryColor,
          content: Text(
            'Présence enregistrée avec succès',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

  Future startSeance(idSeance) async {
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/seance/updateSeanceStatus'),
      body: jsonEncode({
        'idSeance': idSeance,
        'action': "start",
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future stopSeance(idSeance) async {
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/seance/updateSeanceStatus'),
      body: jsonEncode({
        'idSeance': idSeance,
        'action': "stop",
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future deleteSeance(idSeance, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.delete(
      Uri.parse('$BACKEND_URL/api/seance/$idSeance'),
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
