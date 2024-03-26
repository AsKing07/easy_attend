import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';

class ProfDashboard extends StatefulWidget {
  const ProfDashboard({super.key});

  @override
  State<ProfDashboard> createState() => _ProfDashboardState();
}

class _ProfDashboardState extends State<ProfDashboard> {
  late DocumentSnapshot prof;
  bool dataIsLoaded = false;
  List<Widget> myWidgets = [];
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;

  Widget createCourseList(List<Widget> myWidget) {
    return Column(
      children: [for (var w in myWidget) w],
    );
  }

  void loadProf() async {
    final x = await get_Data().loadCurrentProfData();
    setState(() {
      prof = x;
      dataIsLoaded = true;
    });
  }

  Future<void> loadAllActifFilieres() async {
    List<QueryDocumentSnapshot> docsFiliere =
        await get_Data().getActifFiliereData();
    List<Filiere> fil = [];

    docsFiliere.forEach((doc) {
      Filiere filiere = Filiere(
        idDoc: doc.id,
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["idFiliere"],
        statut: doc["statut"],
        niveaux: List<String>.from(
          doc['niveaux'],
        ),
      );

      fil.add(filiere);
    });

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  @override
  void initState() {
    // Récupérez les données de le prof à partir de Firebase
    loadProf();
    loadAllActifFilieres();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !dataIsLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                                width: 5, color: Colors.blueGrey),
                            backgroundColor: AppColors.secondaryColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const startClass()),
                            // );
                          },
                          child: const Text(
                            'Démarrer une nouvelle séance de cours',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    //Dropdown Filieres
                    DropdownButtonFormField<Filiere>(
                      value: _selectedFiliere,
                      elevation: 18,
                      onChanged: (Filiere? value) {
                        setState(() {
                          _selectedFiliere = value!;
                        });
                      },
                      items: Allfilieres.map<DropdownMenuItem<Filiere>>(
                          (Filiere value) {
                        return DropdownMenuItem<Filiere>(
                          value: value,
                          child: Text(value.nomFiliere),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                          labelText: 'Choisissez une filière'),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('cours')
                            .where('professeurId', isEqualTo: prof.id)
                            .where('filiereId',
                                isEqualTo: _selectedFiliere?.idDoc)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            print(snapshot);
                            int length = snapshot.data!.docs.length;
                            var previous = null;
                            myWidgets.clear();
                            for (int i = 0; i < length; i++) {
                              var object = snapshot.data!.docs[i];
                              if (identical(previous, null) == false) {
                                myWidgets.add(Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CourseCard(
                                            name: previous['nomCours'],
                                            niveau: previous['niveau'],
                                            filiere:
                                                _selectedFiliere?.idFiliere,
                                            teacher: prof['nom'],
                                            option: "professeur"),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        CourseCard(
                                            name: object['nomCours'],
                                            niveau: object['niveau'],
                                            filiere:
                                                _selectedFiliere?.idFiliere,
                                            teacher: prof['nom'],
                                            option: "professeur"),
                                      ]),
                                  const SizedBox(height: 10.0),
                                ]));
                                previous = null;
                              } else {
                                previous = object;
                              }
                            }
                            if (identical(previous, null) == false) {
                              myWidgets.add(Row(children: [
                                CourseCard(
                                    name: previous['nomCours'],
                                    niveau: previous['niveau'],
                                    filiere: _selectedFiliere?.idFiliere,
                                    teacher: prof['nom'],
                                    option: "professeur"),
                                const SizedBox(
                                  width: 20.0,
                                ),
                              ]));
                            }

                            return createCourseList(myWidgets);
                          } else {
                            return const Material(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        })
                  ],
                ),
              ),
            ),
    );
  }
}
