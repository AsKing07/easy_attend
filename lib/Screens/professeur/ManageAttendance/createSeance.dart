import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CreateSeancePage extends StatefulWidget {
  DocumentSnapshot course;

  CreateSeancePage({required this.course});

  @override
  State<CreateSeancePage> createState() => _CreateSeancePageState();
}

class _CreateSeancePageState extends State<CreateSeancePage> {
  final dateTimeController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  Time _time = Time(hour: 9, minute: 0);

  bool dataIsloaded = false;
  late DocumentSnapshot course;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        locale: LocaleType.fr,
        minTime: DateTime.now(),
        maxTime: DateTime.now().add(new Duration(days: 365)));
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        dateTimeController.text =
            DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(_dateTime);
      });
    }
  }

  Future loadCourseData() async {
    course = await get_Data().getCourseById(widget.course.id, context);

    setState(() {
      dataIsloaded = true;
    });
  }

  @override
  void initState() {
    initializeDateFormatting('fr');

    loadCourseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return !dataIsloaded
        ? const SizedBox()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              title: Text(
                'Créer une séance de ${course['nomCours']} ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.medium,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Il est l\'heure pour une nouvelle séance de ',
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${course['nomCours']}  - ${course['niveau']} ",
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Sélectionnez la date et l\'heure: ',
                    style: TextStyle(
                      fontSize: FontSize.xxLarge,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      _selectDate(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                    ),
                    child: dateTimeController.text.isEmpty
                        ? const Text(
                            "Sélectionner",
                            style: TextStyle(color: AppColors.white),
                          )
                        : Text(
                            dateTimeController.text,
                            style: const TextStyle(
                                fontSize: FontSize.xMedium,
                                color: AppColors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        if (dateTimeController.text.isEmpty) {
                          GFToast.showToast(
                              "Vous devez sélectionner la date", context);
                        } else {
                          var x = await set_Data()
                              .createSeance(widget.course, _dateTime, context);
                        }
                      },
                      child: Text("Créer la séance",
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.bold,
                          )))
                ],
              ),
            ),
          );
  }
}
