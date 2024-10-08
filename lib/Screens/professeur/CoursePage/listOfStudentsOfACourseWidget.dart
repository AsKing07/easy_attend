// ignore_for_file: camel_case_types, file_names, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeOneStudentAttendance.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

//Liste des étudiants
class listOfStudentsOfACourseWidget extends StatefulWidget {
  final dynamic course;
  const listOfStudentsOfACourseWidget({super.key, required this.course});

  @override
  State<listOfStudentsOfACourseWidget> createState() =>
      _listOfStudentsOfACourseWidgetState();
}

class _listOfStudentsOfACourseWidgetState
    extends State<listOfStudentsOfACourseWidget> {
  final BACKEND_URL = dotenv.env['API_URL'];
  bool dataIsLoaded = false;
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  late final TextEditingController _searchController = TextEditingController();

  String? searchTerm;
  Future<void> fetchData() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/student/getStudentData?idFiliere=${widget.course['idFiliere']}&niveau=${widget.course['niveau']}'));

      if (response.statusCode == 200) {
        List<dynamic> students = jsonDecode(response.body);
        _streamController.add(students);
        setState(() {
          dataIsLoaded = true;
        });
      } else {
        Helper().ErrorMessage(context,
            content: "Impossible de récupérer les étudiants.");
      }
    } catch (e) {
      // Gérer les erreurs ici
      !kReleaseMode
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Impossible de récupérer les étudiants. Erreur:$e'),
                duration: const Duration(seconds: 6),
                backgroundColor: Colors.red,
              ),
            )
          : Helper().ErrorMessage(context,
              content: "Impossible de récupérer les étudiants.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
        });
      },
    );
    return !dataIsLoaded
        ? LoadingAnimationWidget.hexagonDots(
            color: AppColors.secondaryColor, size: 100)
        : SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Liste des étudiants inscrits au cours ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.medium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    "Sélectionnez un étudiant dans la liste",
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 5),
                searchField,
                SizedBox(
                    height: MediaQuery.of(context).size.height - 180,
                    child: StreamBuilder(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                    color: AppColors.secondaryColor,
                                    size: 100));
                          } else if (snapshot.hasError) {
                            return errorWidget(
                                error: snapshot.error.toString());
                          } else {
                            List<dynamic>? students = snapshot.data;
                            if (searchTerm != null &&
                                searchTerm!.isNotEmpty &&
                                students != null) {
                              students = students.where((student) {
                                return student['nom']
                                        .toLowerCase()
                                        .contains(searchTerm!.toLowerCase()) ||
                                    student['prenom']
                                        .toLowerCase()
                                        .contains(searchTerm!.toLowerCase()) ||
                                    student['matricule']
                                        .toString()
                                        .contains(searchTerm!);
                              }).toList();
                            }
                            if (students!
                                .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                            {
                              return const SingleChildScrollView(
                                child: NoResultWidget(),
                              );
                            } else {
                              return ListView.builder(
                                  itemCount: students.length,
                                  itemBuilder: (context, index) {
                                    final etudiant = students![index];
                                    String imageUrl = etudiant['image'] ??
                                        "assets/admin.jpg"; // Default image

                                    return ListTile(
                                      title: Text(
                                          '${etudiant['nom']} ${etudiant['prenom']}'),
                                      subtitle: Text(
                                        '${etudiant['matricule']}',
                                        style: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontSize: FontSize.small),
                                      ),
                                      leading: imageUrl.startsWith('http')
                                          ? GFAvatar(
                                              radius: 30,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: NetworkImage(
                                                imageUrl,
                                              ))
                                          : GFAvatar(
                                              radius: 30,
                                              backgroundColor: Colors.grey[200],
                                              backgroundImage:
                                                  AssetImage(imageUrl),
                                            ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                            Icons.remove_red_eye_sharp),
                                        onPressed: () {
                                          screenSize().isPhone(context)
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          seeOneStudentAttendance(
                                                            course:
                                                                widget.course,
                                                            student: etudiant,
                                                          )),
                                                )
                                              : showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                          child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            0.8,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.8,
                                                        child:
                                                            seeOneStudentAttendance(
                                                          course: widget.course,
                                                          student: etudiant,
                                                        ),
                                                      )));
                                        },
                                      ),
                                      onTap: () {
                                        screenSize().isPhone(context)
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        seeOneStudentAttendance(
                                                          course: widget.course,
                                                          student: etudiant,
                                                        )),
                                              )
                                            : showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                        child: SizedBox(
                                                      width: double.infinity,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.8,
                                                      child:
                                                          seeOneStudentAttendance(
                                                        course: widget.course,
                                                        student: etudiant,
                                                      ),
                                                    )));
                                      },
                                    );
                                  });
                            }
                          }
                        }))
              ],
            ),
          ));
  }
}
