// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/etudiant/MakeQuery/makeQueryMobile.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class MakeQueryMobile extends StatefulWidget {
  const MakeQueryMobile({super.key});

  @override
  State<MakeQueryMobile> createState() => _MakeQueryMobileState();
}

class _MakeQueryMobileState extends State<MakeQueryMobile> {
  final ScrollController _scrollController = ScrollController();
  final BACKEND_URL = dotenv.env['API_URL'];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _objetController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  var _selectedType;
  List<String> type = [
    'Suppression de compte',
    'Demande de permission d\'absence',
    'Justification d\'absence',
    'Autre requête'
  ];

  late Map<String, dynamic> etudiant;
  dynamic studentQuery;
  bool dataIsLoaded = false;

  void loadCurrentStudent() async {
    setState(() {
      dataIsLoaded = false;
    });
    try {
      final x = await get_Data().loadCurrentStudentData();

      final dynamic query = await get_Data().getQueryById(x['uid'], context);

      setState(() {
        etudiant = x;
        studentQuery = null;
      });
      if (query.isNotEmpty) {
        setState(() {
          studentQuery = query;
        });
      }
      setState(() {
        dataIsLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(!kReleaseMode
          ? SnackBar(
              content: Text('Impossible de récupérer les données. Erreur:$e'),
              duration: const Duration(seconds: 6),
              backgroundColor: Colors.red,
            )
          : GFToast.showToast(
              "Impossible de récupérer les données de requête.", context,
              toastPosition: GFToastPosition.TOP,
              toastDuration: const Duration(seconds: 6),
              backgroundColor: AppColors.redColor,
              textStyle: const TextStyle(color: AppColors.white)));
    }
  }

  @override
  void initState() {
    loadCurrentStudent();
    initializeDateFormatting('fr');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
        backgroundColor: AppColors.white,
        body: !dataIsLoaded
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: studentQuery == null
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              SizedBox(
                                height: isSmallScreen
                                    ? screenHeight / 4
                                    : screenHeight / 1.5,
                                child: const Image(
                                  image: AssetImage("assets/makeQuery.jpg"),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Allons-y!",
                                      style: GoogleFonts.poppins(
                                          color: AppColors.secondaryColor,
                                          fontSize: isSmallScreen
                                              ? FontSize.large
                                              : FontSize.xxLarge,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "Formulez et soumettez votre requête en toute facilité",
                                        style: GoogleFonts.poppins(
                                            color: AppColors.secondaryColor,
                                            fontSize: isSmallScreen
                                                ? FontSize.medium
                                                : FontSize.large),
                                      ),
                                    ),
                                    const Text(
                                        "Une requête par étudiant à la fois"),
                                    if (studentQuery != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Center(
                                          child: GFButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Détails de ma requête'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: <Widget>[
                                                          Text(
                                                              'Date: ${DateFormat('EEEE, d MMMM yyyy', 'fr').format(DateTime.parse(studentQuery['dateCreation']).toLocal()).toUpperCase()}'),
                                                          Text(
                                                              'Type: ${studentQuery['type']}'),
                                                          Text(
                                                              'Objet: ${studentQuery['sujet']}'),
                                                          Text(
                                                              'Détails: ${studentQuery['details']}'),
                                                          Text(
                                                              'Statut: ${studentQuery['statut'] == "2" ? "En attente de traitement" : studentQuery['statut'] == "1" ? "Approuvé" : "Rejeté"}'),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      GFButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  GFFloatingWidget(
                                                                      child:
                                                                          GFAlert(
                                                                    title:
                                                                        'Supprimer la requête ?',
                                                                    content:
                                                                        const Text(
                                                                            'Êtes-vous sûr de vouloir supprimer votre requête ?'),
                                                                    bottomBar:
                                                                        Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: <Widget>[
                                                                        GFButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          shape:
                                                                              GFButtonShape.pills,
                                                                          child: const Text(
                                                                              'Annuler',
                                                                              style: TextStyle(color: AppColors.white)),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                5),
                                                                        GFButton(
                                                                          onPressed:
                                                                              () async {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) => Center(
                                                                                      child: LoadingAnimationWidget.hexagonDots(color: AppColors.secondaryColor, size: 100),
                                                                                    ));
                                                                            try {
                                                                              http.Response response = await http.delete(
                                                                                Uri.parse('$BACKEND_URL/api/requete/${studentQuery['idRequete']}'),
                                                                              );

                                                                              if (response.statusCode == 200) {
                                                                                Navigator.pop(context);
                                                                              } else {
                                                                                Helper().ErrorMessage(context);
                                                                              }
                                                                            } catch (e) {
                                                                              Helper().ErrorMessage(context);
                                                                            }

                                                                            loadCurrentStudent();
                                                                            Navigator.of(context).pop();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          color:
                                                                              GFColors.DANGER,
                                                                          shape:
                                                                              GFButtonShape.pills,
                                                                          icon: const Icon(
                                                                              Icons.delete,
                                                                              color: AppColors.white),
                                                                          position:
                                                                              GFPosition.end,
                                                                          text:
                                                                              'Supprimer',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )));
                                                        },
                                                        text: "Supprimer",
                                                        textColor:
                                                            AppColors.white,
//child: Icon(Icons.delete),
                                                        shape:
                                                            GFButtonShape.pills,
                                                        color: GFColors.DANGER,
                                                      ),
                                                      GFButton(
                                                        color: AppColors
                                                            .secondaryColor,
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        shape:
                                                            GFButtonShape.pills,
                                                        child: const Text(
                                                            'Fermer'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            text: "Voir ma requête",
                                            textColor: AppColors.white,
                                            shape: GFButtonShape.pills,
                                            color: AppColors.secondaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: DropdownButtonFormField(
                                              hint: const Text(
                                                'Choisissez le type de requête',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .secondaryColor),
                                              ),
                                              items: type
                                                  .map((item) => DropdownMenuItem(
                                                      value: item,
                                                      child: Text(
                                                          item.toString(),
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .secondaryColor))))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedType = value;
                                                });
                                              },
                                              iconEnabledColor: AppColors
                                                  .secondaryColor, // Arrow color
                                              dropdownColor: Colors
                                                  .white, // Dropdown background color
                                              style: const TextStyle(
                                                  color: Colors
                                                      .black), // Text color
                                              decoration: const InputDecoration(
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                  )),
                                              validator: (value) {
                                                if (value == null) {
                                                  return "Champ obligatoire";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: TextFormField(
                                              controller: _objetController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Champ obligatoire";
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      "Objet de la requête",
                                                  labelStyle: TextStyle(
                                                      color: AppColors
                                                          .secondaryColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: TextFormField(
                                              controller: _detailsController,
                                              maxLines: 5,
                                              minLines: 1,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Champ obligatoire";
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      "Détails de la requête",
                                                  labelStyle: TextStyle(
                                                      color: AppColors
                                                          .secondaryColor),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: AppColors
                                                              .secondaryColor))),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          GFButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                DateTime x = DateTime.now();
                                                await set_Data().createQuery(
                                                    "${etudiant['nom']} ${etudiant['prenom']}",
                                                    etudiant['uid'],
                                                    _selectedType,
                                                    _objetController.text,
                                                    "${etudiant['nom']} ${etudiant['prenom']} : ${_detailsController.text} ",
                                                    "2",
                                                    x,
                                                    context);

                                                loadCurrentStudent();

                                                _objetController.clear();
                                                _detailsController.clear();
                                              }
                                            },
                                            text: "Soumettre",
                                            textStyle: const TextStyle(
                                                color: AppColors.white),
                                            fullWidthButton: true,
                                            color: AppColors.secondaryColor,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
