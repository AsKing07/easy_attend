// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
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

class MakeQueryWeb extends StatefulWidget {
  const MakeQueryWeb({super.key});

  @override
  State<MakeQueryWeb> createState() => _MakeQueryWebState();
}

class _MakeQueryWebState extends State<MakeQueryWeb> {
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
  List<DataRow> rows = [];
  void loadCurrentStudent() async {
    setState(() {
      dataIsLoaded = false;
    });
    try {
      final x = await get_Data().loadCurrentStudentData();

      final dynamic query = await get_Data().getQueryById(x['uid'], context);

      setState(() {
        etudiant = x;
      });
      if (query.isNotEmpty) {
        String date = DateFormat('EEEE, d MMMM yyyy', 'fr')
            .format(DateTime.parse(query['dateCreation']).toLocal());
        String queryStatusFromDB = query["statut"];
        setState(() {
          studentQuery = query;
          rows.add(DataRow(cells: [
            DataCell(Text(date.toUpperCase())),
            DataCell(Text('${query['type']}')),
            DataCell(Text('${query['sujet']}')),
            DataCell(Text('${query['details']}')),
            queryStatusFromDB == "2"
                ? const DataCell(Text(
                    'En attente de traitement',
                    style: TextStyle(color: AppColors.studColor),
                  ))
                : queryStatusFromDB == "1"
                    ? const DataCell(Text(
                        'Approuvé',
                        style: TextStyle(color: AppColors.greenColor),
                      ))
                    : const DataCell(Text(
                        'Rejeté',
                        style: TextStyle(color: AppColors.redColor),
                      )),
            DataCell(GFButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => GFFloatingWidget(
                            child: GFAlert(
                          title: 'Supprimer la requête ?',
                          content: const Text(
                              'Êtes-vous sûr de voouloir supprimer votre requête ?'),
                          bottomBar: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GFButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                shape: GFButtonShape.pills,
                                child: const Text('Annuler',
                                    style: TextStyle(color: AppColors.white)),
                              ),
                              const SizedBox(width: 5),
                              GFButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) => Center(
                                            child: LoadingAnimationWidget
                                                .hexagonDots(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    size: 100),
                                          ));
                                  try {
                                    http.Response response = await http.delete(
                                      Uri.parse(
                                          '$BACKEND_URL/api/requete/${studentQuery['idRequete']}'),
                                    );

                                    if (response.statusCode == 200) {
                                      Navigator.pop(context);
                                    } else {
                                      Helper().ErrorMessage(context);
                                    }
                                  } catch (e) {
                                    Helper().ErrorMessage(context);
                                  }
                                  setState(() {
                                    rows.clear();
                                  });
                                  loadCurrentStudent();
                                  Navigator.of(context).pop();
                                },
                                color: GFColors.DANGER,
                                shape: GFButtonShape.pills,
                                icon: const Icon(Icons.delete,
                                    color: AppColors.white),
                                position: GFPosition.end,
                                text: 'Supprimer',
                              )
                            ],
                          ),
                        )));
              },
              text: "Supprimer",
              textColor: AppColors.white,
//child: Icon(Icons.delete),
              shape: GFButtonShape.square,
              color: GFColors.DANGER,
            ))
          ]));
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
              toastPosition: GFToastPosition.TOP_RIGHT,
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
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: AppColors.white,
        body: !dataIsLoaded
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              )
            : SingleChildScrollView(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: studentQuery == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (studentQuery != null)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                            dataRowMaxHeight: 150,
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.black),
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'Date',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Type',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Objet',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Détails',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Statut',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                'Actions',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                            rows: rows),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: screenHeight / 1.5,
                              child: const Image(
                                image: AssetImage("assets/makeQuery.jpg"),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Allons-y!",
                                    style: GoogleFonts.poppins(
                                        color: AppColors.secondaryColor,
                                        fontSize: FontSize.xxLarge,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Text(
                                      "Faites une demande auprès de l'administration",
                                      style: GoogleFonts.poppins(
                                          color: AppColors.textColor,
                                          fontSize: FontSize.medium,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const Text(
                                      "Une requête par étudiant à la fois"),
                                  const SizedBox(height: 40),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          hint: const Text(
                                            'Choisissez le type de requête',
                                            style: TextStyle(
                                                color:
                                                    AppColors.secondaryColor),
                                          ),
                                          validator: (value) {
                                            if (value == null) {
                                              return "Ce champ est obligatoire";
                                            } else {
                                              return null;
                                            }
                                          },
                                          value: _selectedType,
                                          elevation: 18,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedType = value!;
                                            });
                                          },
                                          items: type
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Center(
                                                    child: Text(
                                                      e,
                                                      style: const TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 3.0,
                                                ),
                                              ),
                                              labelText: 'Choisissez un type'),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                            controller: _objetController,
                                            validator: (value) {
                                              if (_objetController
                                                  .text.isEmpty) {
                                                return "Ce champ est requis";
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Objet de la requête *',
                                              prefixIcon:
                                                  const Icon(Icons.query_stats),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 3.0,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 3.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 3.0),
                                              ),
                                            )),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        TextFormField(
                                            maxLines: 5,
                                            controller: _detailsController,
                                            validator: (value) {
                                              if (_detailsController
                                                  .text.isEmpty) {
                                                return "Ce champ est requis";
                                              }
                                              return null;
                                            },
                                            keyboardType:
                                                TextInputType.multiline,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Détails de la requête *',
                                              prefixIcon:
                                                  const Icon(Icons.query_stats),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 3.0,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 3.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 3.0),
                                              ),
                                            )),
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

                                              setState(() {
                                                rows.clear();
                                              });
                                              loadCurrentStudent();
                                            }
                                          },
                                          text: studentQuery == null
                                              ? "Soumettre"
                                              : "Mettre à jour",
                                          textStyle: GoogleFonts.poppins(
                                            color: AppColors.white,
                                            fontSize: FontSize.medium,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          color: AppColors.secondaryColor,
                                          shape: GFButtonShape.pills,
                                          fullWidthButton: true,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )));
  }
}
