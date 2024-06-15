// ignore_for_file: camel_case_types, non_constant_identifier_names, use_build_context_synchronously

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';

import 'package:easy_attend/Screens/professeur/CoursePage/createNewSeanceWidget.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/listOfStudentsOfACourseWidget.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/listOfOneCourseSeance.dart';

import 'package:flutter/material.dart';

import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class OneCoursePageWebWidget extends StatefulWidget {
  final dynamic course;
  final String nomFiliere;
  const OneCoursePageWebWidget(
      {super.key, required this.course, required this.nomFiliere});

  @override
  State<OneCoursePageWebWidget> createState() => _OneCoursePageWebWidgetState();
}

class _OneCoursePageWebWidgetState extends State<OneCoursePageWebWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    loadProf();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  var professeur;
  bool dataIsLoaded = false;
  late TabController tabController;

  void loadProf() async {
    final prof =
        await get_Data().getProfById(widget.course['idProfesseur'], context);
    setState(() {
      professeur = prof;
      dataIsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return !dataIsLoaded
        ? LoadingAnimationWidget.hexagonDots(
            color: AppColors.secondaryColor, size: 100)
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.course['nomCours']}',
                              style: const TextStyle(
                                fontSize: FontSize.xLarge,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "${widget.nomFiliere}  - ${widget.course['niveau']} ",
                              style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: FontSize.medium,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Professeur : ${professeur['nom']} ${professeur['prenom']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: FontSize.medium,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              height: 200,
                              child: const Image(
                                  image: AssetImage("assets/coursImage.jpg")),
                            )
                          ],
                        ),
                      )),
                  Expanded(
                      child: Card(
                          surfaceTintColor: Theme.of(context).cardColor,
                          color: Theme.of(context).cardColor,
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GFTabBar(
                                  indicatorColor: AppColors.secondaryColor,
                                  tabBarColor: Theme.of(context).cardColor,
                                  width: screenWidth / 2.5,
                                  tabBarHeight: 58,
                                  length: 3,
                                  controller: tabController,
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.settings),
                                      child: Text(
                                        'Gérer les séances',
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(Icons.create),
                                      child: Text(
                                        'Créer une séance',
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(Icons.people),
                                      child: Text(
                                        'Listes des étudiants',
                                      ),
                                    ),
                                  ],
                                ),
                                GFTabBarView(
                                  height: screenHeight / 2,
                                  controller: tabController,
                                  children: <Widget>[
                                    listOfoneCourseSeanceWidget(
                                      course: widget.course,
                                    ),
                                    CreateNewSeanceWidget(
                                        course: widget.course),
                                    listOfStudentsOfACourseWidget(
                                      course: widget.course,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            ),
          );
  }
}
