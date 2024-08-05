// ignore_for_file: use_build_context_synchronously, must_be_immutable, file_names, non_constant_identifier_names, empty_catches, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeAttendance.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TakeManualAttendance extends StatefulWidget {
  final seance, course;
  final Function() callback;

  TakeManualAttendance(
      {super.key,
      required this.seance,
      required this.course,
      required this.callback});

  @override
  State<TakeManualAttendance> createState() => _TakeManualAttendanceState();
}

class _TakeManualAttendanceState extends State<TakeManualAttendance> {
  bool dataIsloaded = false;
  late List<Map<String, dynamic>> presenceEtudiant;
  late Map<String, dynamic> oldPresenceEtudiant;

  late List<Etudiant> AllEtudiant = [];
  late List<Etudiant> SearchedEtudiant = [];
  late final TextEditingController _searchController = TextEditingController();

  String? searchTerm;

  Future getEtudiantsCours() async {
    try {
      final List<dynamic> etudiantDoc = await get_Data()
          .getEtudiantsOfAFiliereAndNiveau(
              widget.course['idFiliere'], widget.course['niveau']);

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
            statut: doc['statut'] == 1,
            imageUrl: doc['image']);

        etudiants.add(etudiant);
      }
      oldPresenceEtudiant = jsonDecode(widget.seance['presenceEtudiant']);

      setState(() {
        AllEtudiant.addAll(etudiants);
        SearchedEtudiant = List.from(AllEtudiant);
        presenceEtudiant = List.generate(etudiants.length, (index) {
          return {
            'id': etudiants[index].uid,
            'present': oldPresenceEtudiant['${etudiants[index].uid}'] == true
          };
        });

        dataIsloaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Impossible de récupérer les étudiants de ce cours. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> enregistrerPresence() async {
    // Récupérer l'ID de la séance
    String seanceId = widget.seance['idSeance'].toString();

    // Créer un Map pour stocker les présences
    Map<String, bool> presenceEtudiantsMap = {};
    for (int i = 0; i < AllEtudiant.length; i++) {
      presenceEtudiantsMap[AllEtudiant[i].uid!] =
          presenceEtudiant[i]['present'];
    }

    // Mettre à jour
    await set_Data()
        .updateSeancePresence(seanceId, presenceEtudiantsMap, context);

    widget.callback();
    if (screenSize().isPhone(context)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SeeSeanceAttendanceProf(
                  seance: widget.seance, course: widget.course)));
    } else {
      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (context) => Dialog(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SeeSeanceAttendanceProf(
                      seance: widget.seance, course: widget.course))));
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
    TextFormField searchField = TextFormField(
      controller: _searchController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Rechercher',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.only(top: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.secondaryColor,
            width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              const BorderSide(color: AppColors.secondaryColor, width: 3.0),
        ),
      ),
      onChanged: (value) {
        setState(() {
          searchTerm = value;
          SearchedEtudiant = AllEtudiant.where((etudiant) {
            final fullName = "${etudiant.nom} ${etudiant.prenom}".toLowerCase();
            return fullName.contains(searchTerm!.toLowerCase());
          }).toList();
        });
      },
    );

    return dataIsloaded == false
        ? Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.secondaryColor, size: 100),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                screenSize().isLargeScreen(context)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('Cours: ${widget.course['nomCours']}',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textColor,
                                      fontSize: FontSize.xxLarge,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  'Séance du ${DateFormat('EEEE, d MMM yy, hh:mm', 'fr').format(DateTime.parse(widget.seance['dateSeance']).toLocal().subtract(const Duration(hours: 1))).toUpperCase()}',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.primaryColor,
                                      fontSize: FontSize.medium,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GFButton(
                              color: AppColors.secondaryColor,
                              onPressed: () async {
                                await enregistrerPresence();
                              },
                              text: "Enregistrer",
                              textStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: FontSize.large,
                                  fontWeight: FontWeight.bold),
                              shape: GFButtonShape.square,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(' ${widget.course['nomCours']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor,
                                    fontSize: FontSize.xxLarge,
                                    fontWeight: FontWeight.w600)),
                            Text(
                                'Séance du ${DateFormat('EEEE, d MMM yy, hh:mm', 'fr').format(DateTime.parse(widget.seance['dateSeance']).toLocal().subtract(const Duration(hours: 1))).toUpperCase()}',
                                style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontSize: FontSize.medium,
                                    fontWeight: FontWeight.w600)),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: GFButton(
                                color: AppColors.secondaryColor,
                                onPressed: () async {
                                  await enregistrerPresence();
                                },
                                text: "Enregistrer",
                                textStyle: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: FontSize.large,
                                    fontWeight: FontWeight.bold),
                                shape: GFButtonShape.square,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: searchField,
                ),
                const SizedBox(height: 40),
                Flexible(
                  child: ListView.builder(
                    itemCount: SearchedEtudiant.length,
                    itemBuilder: (context, index) {
                      String imageUrl = SearchedEtudiant[index].imageUrl ??
                          "assets/admin.jpg"; // Default image

                      return GFCheckboxListTile(
                        titleText:
                            "${SearchedEtudiant[index].nom} ${SearchedEtudiant[index].prenom}",
                        value: presenceEtudiant[
                                AllEtudiant.indexOf(SearchedEtudiant[index])]
                            ['present'],
                        avatar: imageUrl.startsWith('http')
                            ? GFAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  imageUrl,
                                ))
                            : GFAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage: AssetImage(imageUrl),
                              ),
                        activeBgColor: Colors.green,
                        type: GFCheckboxType.circle,
                        activeIcon: const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            presenceEtudiant[AllEtudiant.indexOf(
                                SearchedEtudiant[index])]['present'] = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
