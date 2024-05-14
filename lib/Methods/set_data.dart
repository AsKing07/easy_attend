// ignore_for_file: use_build_context_synchronously, camel_case_types, unused_local_variable

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Cours.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfOneCourseSeance.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      Uri.parse('$BACKEND_URL/api/global/getFiliereBySigle/$id'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // La filière existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().filiereExistanteMessage(context);
    } else {
      // La filière n'existe pas encore, ajouter la nouvelle filière
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/admin/filiere'),
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
  // Future<void> ajouterFiliere(
  //     String nom, String id, List<String> niveaux, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 300),
  //           ));
  //   final docSnapshot =
  //       await FirebaseFirestore.instance.collection('filiere').doc(id).get();
  //   if (docSnapshot.exists) {
  //     // La filière existe déjà, afficher un message d'erreur
  //     Navigator.pop(context);
  //     Helper().filiereExistanteMessage(context);
  //   } else {
  //     // La filière n'existe pas encore, ajouter la nouvelle filière
  //     await FirebaseFirestore.instance.collection('filiere').add({
  //       'nomFiliere': nom.toUpperCase().trim(),
  //       'idFiliere': id.toUpperCase().trim(),
  //       'niveaux': niveaux,
  //       'statut': "1",
  //     }).then((value) {
  //       // Filère ajoutée avec succès
  //       Navigator.pop(context);
  //       Helper().succesMessage(context);
  //     }).catchError((error) {
  //       // Une erreur s'est produite lors de l'ajout de la filière
  //       Navigator.pop(context);
  //       Helper().ErrorMessage(context);
  //     });
  //   }
  // }

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
      Uri.parse('$BACKEND_URL/api/admin/filiere'),
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
  // void modifierFiliere(
  //     filiereId, nomFiliere, idFiliere, niveaux, BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   FirebaseFirestore.instance.collection('filiere').doc(filiereId).update({
  //     'nomFiliere': nomFiliere.toString().toUpperCase().trim(),
  //     'idFiliere': idFiliere.toString().toUpperCase().trim(),
  //     'niveaux': niveaux,
  //   }).then((value) {
  //     // Filière modifiée avec succès
  //     Navigator.pop(context);
  //     Helper().succesMessage(context);
  //   }).catchError((error) {
  //     // Une erreur s'est produite lors de la modification de la filière
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   });
  // }

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
        Uri.parse('$BACKEND_URL/api/admin/filiere/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Supprimer les cours
        http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/admin/deleteCoursesByFiliere/$id'),
        );
        // Supprimer les  étudiants
        response = await http.delete(
          Uri.parse('$BACKEND_URL/api/admin/deleteStudentsByFiliere/$id'),
        );
      } else {
        // La requête a échoué, gérer l'erreur ici
        print('Erreur lors de la suppression des données');
      }

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> deleteFiliere(
  //   id,
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Supprimez la filière de Firestore
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('filiere')
  //         .doc(id)
  //         .update({'statut': "0"});
  //     //Supprimer les cours associés
  //     FirebaseFirestore.instance
  //         .collection('cours')
  //         .where('filiereId', isEqualTo: id)
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "0"});
  //       }
  //     });
  //     //Supprimer les  étudiants associé
  //     FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .where('idFiliere', isEqualTo: id)
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "0"});
  //       }
  //     });
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
        Uri.parse('$BACKEND_URL/api/admin/filiere/$id'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Restaurer les  étudiants
        response = await http.get(
          Uri.parse('$BACKEND_URL/api/admin/restaureStudentsByFiliere/$id'),
        );
      } else {
        // La requête a échoué, gérer l'erreur ici
        print('Erreur lors de la restauration des données');
      }

      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> restoreFiliere(
  //   id,
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Restaurer la filière de Firestore
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('filiere')
  //         .doc(id)
  //         .update({'statut': "1"});
  //     //Restaurer les cours associés
  //     FirebaseFirestore.instance
  //         .collection('cours')
  //         .where('filiereId', isEqualTo: id)
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "1"});
  //       }
  //     });
  //     //
  //     //Restaurer les  étudiants associés
  //     FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .where('idFiliere', isEqualTo: id)
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "1"});
  //       }
  //     });
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

  //Supprimer toutes les filières
  Future<void> deleteAllFiliere(BuildContext context) async {
    try {
      showDialog(
          context: context,
          builder: (context) => Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 200),
              ));

      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/admin/filiere'),
      );

      if (response.statusCode == 200) {
        // La requête a réussi, traiter la réponse ici

        // Supprimer les cours
        http.Response response = await http.delete(
          Uri.parse('$BACKEND_URL/api/admin/courses'),
        );
        // Supprimer les  étudiants
        response = await http.delete(
          Uri.parse('$BACKEND_URL/api/admin/students'),
        );
      } else {
        // La requête a échoué, gérer l'erreur ici
        print('Erreur lors de la suppression des données');
      }
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> deleteAllFiliere(BuildContext context) async {
  //   try {
  //     showDialog(
  //         context: context,
  //         builder: (context) => Center(
  //               child: LoadingAnimationWidget.hexagonDots(
  //                   color: AppColors.secondaryColor, size: 200),
  //             ));
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection("filiere").get();
  //     for (var doc in querySnapshot.docs) {
  //       doc.reference.update({'statut': "0"});
  //     }
  //     // Supprimer les cours
  //     FirebaseFirestore.instance
  //         .collection('cours')
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "0"});
  //       }
  //     });
  //     // Supprimer les  étudiants
  //     FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .get()
  //         .then((QuerySnapshot querySnapshot) {
  //       for (var doc in querySnapshot.docs) {
  //         doc.reference.update({'statut': "0"});
  //       }
  //     });
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
          Uri.parse('$BACKEND_URL/api/admin/prof/$id'),
          headers: {'Content-Type': 'application/json'});
      Navigator.pop(context);
      if (response.statusCode != 200) {
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> deleteProf(
  //   id,
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Update le statut du prof dans Firestore
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('prof')
  //         .doc(id)
  //         .update({"statut": "0"});
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

  //Supprimer tous les prof

  // Future<void> deleteAllProf(
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Update le statut du prof dans Firestor
  //   try {
  //     QuerySnapshot snapshots =
  //         await FirebaseFirestore.instance.collection('prof').get();
  //     for (var document in snapshots.docs) {
  //       await document.reference.update({"statut": "0"});
  //     }
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }
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
          Uri.parse('$BACKEND_URL/api/admin/prof'),
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
        Uri.parse('$BACKEND_URL/api/admin/prof/$id'),
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
// Future<void> restoreProf(
//     id,
//     BuildContext context,
//   ) async {
//     showDialog(
//         context: context,
//         builder: (context) => Center(
//               child: LoadingAnimationWidget.hexagonDots(
//                   color: AppColors.secondaryColor, size: 100),
//             ));
//     // Update le statut du prof dans Firestore
//     try {
//       FirebaseFirestore.instance
//           .collection('prof')
//           .doc(id)
//           .update({"statut": "1"});
//       Navigator.pop(context);
//     } catch (e) {
//       Helper().ErrorMessage(context);
//     }
//   }
//Modifier prof

  Future<void> modifierProfByAdmin(
      profId, nom, prenom, phone, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/admin/prof'),
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
      print(response.body);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> modifierProfByAdmin(
  //     profId, nom, prenom, phone, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   FirebaseFirestore.instance.collection('prof').doc(profId).update({
  //     'nom': nom.toString().toUpperCase().trim(),
  //     'phone': phone.toString().toUpperCase().trim(),
  //     'prenom': prenom.toString().toUpperCase().trim(),
  //   }).then((value) {
  //     // Prof modifié avec succès
  //     Navigator.pop(context);
  //     Helper().succesMessage(context);
  //   }).catchError((error) {
  //     // Une erreur s'est produite lors de la modification de la filière
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   });
  // }

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
      Uri.parse('$BACKEND_URL/api/global/getCourseBySigle/${cours.idCours}'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // Le cours existe déjà, afficher un message d'erreur
      Navigator.pop(context);
      Helper().coursExistantMessage(context);
    } else {
      // Le cours n'existe pas encore, ajouter le
      http.Response response = await http.post(
        Uri.parse('$BACKEND_URL/api/admin/courses'),
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
  // Future<void> ajouterCours(Cours cours, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   final docSnapshot = await FirebaseFirestore.instance
  //       .collection('cours')
  //       .where('idCours', isEqualTo: cours.idCours.toString().trim())
  //       .get();
  //   if (docSnapshot.docs.isNotEmpty) {
  //     // Le cours existe déjà, afficher un message d'erreur
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   } else {
  //     // Le cours n'existe pas encore, ajouter
  //     await FirebaseFirestore.instance.collection('cours').add({
  //       'nomCours': cours.nomCours.toUpperCase().trim(),
  //       'idCours': cours.idCours.trim(),
  //       'niveau': cours.niveau.toUpperCase().trim(),
  //       'filiereId': cours.filiereId.toString().trim(),
  //       'professeurId': cours.professeurId!.trim(),
  //       'statut': "1"
  //     }).then((value) {
  //       // Cours ajouté avec succès
  //       Navigator.pop(context);
  //       Helper().succesMessage(context);
  //     }).catchError((error) {
  //       // Une erreur s'est produite lors de l'ajout du cours
  //       Navigator.pop(context);
  //       Helper().ErrorMessage(context);
  //     });
  //   }
  // }

//Modifier cours
  Future<void> modifierCours(Cours cours, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));

    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/admin/courses'),
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
//Modifier cours
  // Future<void> modifierCours(Cours cours, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   await FirebaseFirestore.instance
  //       .collection('cours')
  //       .doc(cours.idDoc)
  //       .update({
  //     'nomCours': cours.nomCours.toUpperCase().trim(),
  //     'idCours': cours.idCours.toUpperCase().trim(),
  //     'niveau': cours.niveau.toUpperCase().trim(),
  //     'filiereId': cours.filiereId!.trim(),
  //     'professeurId': cours.professeurId!.trim()
  //   }).then((value) {
  //     // Cours modifié avec succès
  //     Navigator.pop(context);
  //     Helper().succesMessage(context);
  //   }).catchError((error) {
  //     // Une erreur s'est produite lors de la modification du cours
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   });
  // }

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
    // Supprimez le cours de Firestore

    try {
      http.Response response = await http.delete(
        Uri.parse('$BACKEND_URL/api/admin/courses/$id'),
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
  // Future<void> deleteCours(
  //   id,
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Supprimez le cours de Firestore
  //   try {
  //     FirebaseFirestore.instance.collection('cours').doc(id).delete();
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
  // Future<void> deleteAllCours(
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Supprimez les cours de Firestore
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection("cours").get();
  //     for (var doc in querySnapshot.docs) {
  //       doc.reference.delete();
  //     }
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
          '$BACKEND_URL/api/global/getStudentByMatricule?matricule=${matricule.toString().toUpperCase()}&id=$idEtudiant'),
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
        Uri.parse('$BACKEND_URL/api/admin/students'),
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
        print(response.body);
      }
    }
  }

  // Future<void> modifierEtudiantByAdmin(idEtudiant, nom, prenom, phone, filiere,
  //     idFiliere, niveau, matricule, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   final docSnapshot = await FirebaseFirestore.instance
  //       .collection('etudiant')
  //       .where('matricule', isEqualTo: matricule.toString().toUpperCase())
  //       .where(FieldPath.documentId, isNotEqualTo: idEtudiant)
  //       .get();
  //   if (docSnapshot.docs.isNotEmpty) {
  //     Navigator.pop(context);
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return myErrorWidget(
  //             content: "Un étudiant avec le même matricule existe déjà.",
  //             height: 160);
  //       },
  //     );
  //   } else {
  //     FirebaseFirestore.instance.collection('etudiant').doc(idEtudiant).update({
  //       'nom': nom.toString().toUpperCase().trim(),
  //       'phone': phone.toString().toUpperCase().trim(),
  //       'prenom': prenom.toString().toUpperCase().trim(),
  //       'filiere': filiere.toString().toUpperCase().trim(),
  //       'idFiliere': idFiliere.toString().trim(),
  //       'niveau': niveau.toString().toUpperCase().trim(),
  //       'matricule': matricule.toString().toUpperCase().trim()
  //     }).then((value) {
  //       // Etudiant modifié avec succès
  //       Navigator.pop(context);
  //       Helper().succesMessage(context);
  //     }).catchError((error) {
  //       // Une erreur s'est produite lors de la modification
  //       Navigator.pop(context);
  //       Helper().ErrorMessage(context);
  //     });
  //   }
  // }

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
        Uri.parse('$BACKEND_URL/api/admin/students/$id'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> deleteOneStudent(id, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Update le statut de l'étudiant dans  Firestore
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .doc(id)
  //         .update({"statut": "0"});
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
        Uri.parse('$BACKEND_URL/api/admin/students'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // //Delete All Students
  // Future<void> deleteAllStudents(
  //   BuildContext context,
  // ) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     // Supprimer les  étudiants
  //     QuerySnapshot snapshots =
  //         await FirebaseFirestore.instance.collection('etudiant').get();
  //     for (var document in snapshots.docs) {
  //       await document.reference.update({"statut": "0"});
  //     }
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
        Uri.parse('$BACKEND_URL/api/admin/students/$id'),
      );
      Navigator.pop(context);
    } catch (e) {
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> restoreOneStudent(id, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   // Update le statut de l'étudiant dans  Firestore
  //   try {
  //     FirebaseFirestore.instance
  //         .collection('etudiant')
  //         .doc(id)
  //         .update({"statut": "1"});
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
      Uri.parse('$BACKEND_URL/api/admin/updateRequestStatus'),
      body: jsonEncode({
        'idRequete': idRequete,
        'action': "Approuver",
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      //succès
      Navigator.pop(context);
    } else {
      // Une erreur s'est produite

      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> approuverRequete(idRequete, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("requete")
  //         .doc(idRequete)
  //         .update({"statut": "1"});
  //     if (!context.mounted) return;
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

  //Désapprouver requete
  Future<void> desapprouverRequete(idRequete, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/admin/updateRequestStatus'),
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
  // Future<void> desapprouverRequete(idRequete, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("requete")
  //         .doc(idRequete)
  //         .update({"statut": "0"});
  //     if (!context.mounted) return;
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

  //Mettre requete en attente
  Future<void> mettreEnAttenteRequete(idRequete, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/admin/updateRequestStatus'),
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
  // Future<void> mettreEnAttenteRequete(idRequete, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("requete")
  //         .doc(idRequete)
  //         .update({"statut": "2"});
  //     if (!context.mounted) return;
  //     Navigator.pop(context);
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

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
        Uri.parse('$BACKEND_URL/api/global/createRequest'),
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
      print(response.body);

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
      print(e);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }
  // Future<void> createQuery(auteur, idAuteur, type, sujet, details, statut,
  //     dateCreation, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     await FirebaseFirestore.instance.collection("requete").doc(idAuteur).set({
  //       "auteur": auteur,
  //       "idAuteur": idAuteur,
  //       "type": type,
  //       "sujet": sujet,
  //       "details": details,
  //       "statut": "2",
  //       "dateCreation": dateCreation
  //     });
  //     Navigator.pop(context);
  //     Helper().succesMessage(context);
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

//METHODES DES SEANCES
//Mettre à jour présence

  Future<void> updatePresenceEtudiant(String seanceId, String etudiantId,
      bool present, BuildContext context) async {
    try {
      showDialog(
          context: context,
          builder: (context) => Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              ));

      // Récupérer le document existant
      DocumentSnapshot seanceSnapshot = await FirebaseFirestore.instance
          .collection('seance')
          .doc(seanceId)
          .get();

      // Vérifier si le document existe
      if (seanceSnapshot.exists) {
        // Récupérer la liste des présences
        Map<String, dynamic>? presenceEtudiant =
            seanceSnapshot.get('presenceEtudiant');

        presenceEtudiant ??= {};

        // Rechercher l'étudiant dans la liste et mettre à jour sa présence
        // if (presenceEtudiant.containsKey(etudiantId)) {
        //   presenceEtudiant[etudiantId] = present;
        // }

        presenceEtudiant[etudiantId] = present;

        // Mettre à jour le document Firebase avec les nouvelles données
        await FirebaseFirestore.instance
            .collection('seance')
            .doc(seanceId)
            .update({
          'presenceEtudiant': presenceEtudiant,
        });

        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }

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
        Uri.parse('$BACKEND_URL/api/teacher/createSeance'),
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
      print(response.body);

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
      print(e);
      Navigator.pop(context);
      Helper().ErrorMessage(context);
    }
  }
  // Future createSeance(
  //     DocumentSnapshot course, dateSeance, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   try {
  //     Map<String, bool> presenceEtudiantsMap = {};
  //     DocumentSnapshot cours =
  //         await get_Data().getCourseById(course.id, context);
  //     final List<QueryDocumentSnapshot> etudiantDoc = await get_Data()
  //         .getEtudiantsOfAFiliereAndNiveau(cours['filiereId'], cours['niveau']);
  //     List<Etudiant> etudiants = [];
  //     for (var doc in etudiantDoc) {
  //       final etudiant = Etudiant(
  //           uid: doc.id,
  //           matricule: doc['matricule'],
  //           nom: doc['nom'],
  //           prenom: doc['prenom'],
  //           phone: doc['phone'],
  //           idFiliere: doc['idFiliere'],
  //           filiere: doc["filiere"],
  //           niveau: doc['niveau'],
  //           statut: doc['statut']);
  //       etudiants.add(etudiant);
  //     }
  //     List<Map<String, dynamic>> presenceEtudiant =
  //         List.generate(etudiants.length, (index) {
  //       return {'id': etudiants[index].uid, 'present': false};
  //     });
  //     for (int i = 0; i < etudiants.length; i++) {
  //       presenceEtudiantsMap[etudiants[i].uid!] =
  //           presenceEtudiant[i]['present'];
  //     }
  //     var x = await FirebaseFirestore.instance.collection('seance').add({
  //       'idCours': course.id.toString().trim(),
  //       'dateSeance': dateSeance,
  //       'presenceEtudiant': presenceEtudiantsMap,
  //       'isActive': false,
  //       'seanceCode': randomAlphaNumeric(6).toUpperCase(),
  //       'presenceTookOnce': false
  //     });
  //     Navigator.pop(context);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => ListOfOneCourseSeancePage(
  //                 course: course,
  //               )),
  //     );
  //   } catch (e) {
  //     Navigator.pop(context);
  //     Helper().ErrorMessage(context);
  //   }
  // }

  Future updateSeancePresence(idSeance, presence, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 200),
            ));
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/teacher/updateSeancePresence'),
      body: jsonEncode({
        'idSeance': idSeance,
        'presenceEtudiant': presence,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Présence enregistrée avec succès'),
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
      Uri.parse('$BACKEND_URL/api/teacher/updateSeanceStatus'),
      body: jsonEncode({
        'idSeance': idSeance,
        'action': "start",
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future stopSeance(idSeance) async {
    http.Response response = await http.put(
      Uri.parse('$BACKEND_URL/api/teacher/updateSeanceStatus'),
      body: jsonEncode({
        'idSeance': idSeance,
        'action': "stop",
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
  // Future starSeance(idSeance) async {
  //   var x = await FirebaseFirestore.instance
  //       .collection('seance')
  //       .doc(idSeance)
  //       .update({
  //     'isActive': true,
  //   });
  // }
  // Future stopSeance(idSeance) async {
  //   var x = await FirebaseFirestore.instance
  //       .collection('seance')
  //       .doc(idSeance)
  //       .update({
  //     'isActive': false,
  //   });
  // }

  Future deleteSeance(idSeance, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    http.Response response = await http.delete(
      Uri.parse('$BACKEND_URL/api/teacher/deleteSeance/$idSeance'),
      headers: {'Content-Type': 'application/json'},
    );
    // print(response.body);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  // Future deleteSeance(idSeance, BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) => Center(
  //             child: LoadingAnimationWidget.hexagonDots(
  //                 color: AppColors.secondaryColor, size: 100),
  //           ));
  //   await FirebaseFirestore.instance
  //       .collection('seance')
  //       .doc(idSeance)
  //       .delete();
  //   Navigator.pop(context);
  //   Navigator.pop(context);
  // }
}
