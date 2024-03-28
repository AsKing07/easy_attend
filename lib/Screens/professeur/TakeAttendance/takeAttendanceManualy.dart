// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TakeManualAttendance extends StatefulWidget {
  String seanceId, courseId;
  TakeManualAttendance({required this.seanceId, required this.courseId});

  @override
  State<TakeManualAttendance> createState() => _TakeManualAttendanceState();
}

class _TakeManualAttendanceState extends State<TakeManualAttendance> {
  late DocumentSnapshot course;
  late DocumentSnapshot seance;
  bool dataIsloaded = false;
  late List<Map<String, dynamic>> presenceEtudiant;

  late List<Etudiant> AllEtudiant = [];

  Future getEtudiantsCours() async {
    try {
      await loadCourseSeance();
      final List<QueryDocumentSnapshot> etudiantDoc = await get_Data()
          .getEtudiantsOfAFiliereAndNiveau(
              course['filiereId'], course['niveau']);

      List<Etudiant> etudiants = [];
      print(etudiantDoc.length);
      etudiantDoc.forEach((doc) {
        final etudiant = Etudiant(
            uid: doc.id,
            matricule: doc['matricule'],
            nom: doc['nom'],
            prenom: doc['prenom'],
            phone: doc['phone'],
            idFiliere: doc['idFiliere'],
            filiere: doc["filiere"],
            niveau: doc['niveau'],
            statut: doc['statut']);

        etudiants.add(etudiant);
      });
      DocumentSnapshot se = await FirebaseFirestore.instance
          .collection('seance')
          .doc(widget.seanceId)
          .get();

      setState(() {
        seance = se;
        AllEtudiant.addAll(etudiants);
        presenceEtudiant = List.generate(etudiants.length, (index) {
          return {'id': etudiants[index].uid, 'present': false};
        });
        dataIsloaded = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadCourseSeance() async {
    DocumentSnapshot cours =
        await get_Data().getCourseById(widget.courseId, context);
    setState(() {
      course = cours;
    });
  }

  Future<void> enregistrerPresence() async {
    try {
      // Récupérer l'ID de la séance
      String seanceId = widget.seanceId;

      // Créer un Map pour stocker les présences
      Map<String, bool> presenceEtudiantsMap = {};
      for (int i = 0; i < AllEtudiant.length; i++) {
        presenceEtudiantsMap[AllEtudiant[i].uid!] =
            presenceEtudiant[i]['present'];
      }
      print(presenceEtudiantsMap);
      print(presenceEtudiant);

      // Mettre à jour le document Firebase
      await FirebaseFirestore.instance
          .collection('seance')
          .doc(seanceId)
          .update({
        'presenceEtudiant': presenceEtudiantsMap,
      });

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Présence enregistrée avec succès'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getEtudiantsCours();

    initializeDateFormatting('fr');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return dataIsloaded == false
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Prise de présence ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.medium,
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text('Cours: ${course['nomCours']}',
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600)),
                Text(
                    'Séance du ${DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(seance['dateSeance'].toDate())}',
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 70),
                Flexible(
                    child: ListView.builder(
                        itemCount: AllEtudiant.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(
                                '${AllEtudiant[index].nom} ${AllEtudiant[index].prenom}'),
                            value: presenceEtudiant[index]['present'],
                            onChanged: (value) {
                              setState(() {
                                presenceEtudiant[index]['present'] = value!;
                              });
                            },
                          );
                        })),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      await enregistrerPresence();
                    },
                    child: const Text('Enregistrer la présence'),
                  ),
                ),
              ],
            ),
          );
  }
}
