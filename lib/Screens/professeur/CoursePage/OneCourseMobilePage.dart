// ignore_for_file: must_be_immutable, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/seeAttendance/listOfCourse.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/createNewSeanceWidget.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/listOfOneCourseSeance.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/listOfStudentsOfACourseWidget.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneCourseMobilePage extends StatefulWidget {
  final dynamic course;
  final String? nomFiliere;

  const OneCourseMobilePage(
      {super.key, required this.course, required this.nomFiliere});

  @override
  State<OneCourseMobilePage> createState() => _OneCoursePageMobileState();
}

class _OneCoursePageMobileState extends State<OneCourseMobilePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    loadProf();
    tabController = TabController(length: 3, vsync: this);

    super.initState();
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
    var currentPage = Provider.of<PageModelProf>(context);
    var currentPageAdmin = Provider.of<PageModelAdmin>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return !dataIsLoaded
        ? LoadingAnimationWidget.hexagonDots(
            color: AppColors.secondaryColor, size: 100)
        : Scaffold(
            body: SingleChildScrollView(
                child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Que souhaitez-vous faire ?",
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  GFButton(
                      fullWidthButton: false,
                      shape: GFButtonShape.pills,
                      text: "RETOUR",
                      color: GFColors.DANGER,
                      textStyle: const TextStyle(color: AppColors.white),
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final String role = prefs.getString("role") ?? "";
                        if (role == "admin") {
                          try {
                            currentPageAdmin.updatePage(MenuItems(
                              text: 'Présences',
                              tap: const listOfCourse(),
                            ));
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          print("Prof");
                          currentPage.updatePage(currentPage.basePage);
                        }
                      }),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 200,
                    child: Image(image: AssetImage("assets/coursImage.jpg")),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "${widget.course['nomCours']} ",
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        "${widget.nomFiliere}",
                        style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        textAlign: TextAlign.end,
                        '${widget.course['niveau']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.medium,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    '${professeur['nom']} ${professeur['prenom']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.medium,
                      color: Colors.black,
                    ),
                  ),
                  Divider(color: Colors.grey[400]),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: GFTabBar(
                            indicatorColor: AppColors.secondaryColor,
                            tabBarColor: Theme.of(context).cardColor,
                            tabBarHeight: 58,
                            length: 3,
                            controller: tabController,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.settings),
                                // child: Text(
                                //   'Gérer les séances',
                                // ),
                              ),
                              Tab(
                                icon: Icon(Icons.create),
                                // child: Text(
                                //   'Créer une séance',
                                // ),
                              ),
                              Tab(
                                icon: Icon(Icons.people),
                                // child: Text(
                                //   'Listes des étudiants',
                                // ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: GFTabBarView(
                            height: 500,
                            controller: tabController,
                            children: <Widget>[
                              listOfoneCourseSeanceWidget(
                                course: widget.course,
                              ),
                              CreateNewSeanceWidget(course: widget.course),
                              listOfStudentsOfACourseWidget(
                                course: widget.course,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
          );
  }
}
