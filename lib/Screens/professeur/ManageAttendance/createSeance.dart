// ignore_for_file: must_be_immutable, file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';

class CreateSeancePage extends StatefulWidget {
  final dynamic course;

  const CreateSeancePage({super.key, required this.course});

  @override
  State<CreateSeancePage> createState() => _CreateSeancePageState();
}

class _CreateSeancePageState extends State<CreateSeancePage> {
  final dateTimeController = TextEditingController();

  DateTime _dateTime = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        locale: LocaleType.fr,
        minTime: DateTime.now(),
        maxTime: DateTime.now().add(const Duration(days: 365)));
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        dateTimeController.text =
            DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(_dateTime);
      });
    }
  }

  @override
  void initState() {
    initializeDateFormatting('fr');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Créer une séance de ${widget.course['nomCours']} ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: Center(
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
              textAlign: TextAlign.center,
            ),
            Text(
              "${widget.course['nomCours']}  - ${widget.course['niveau']} ",
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
                backgroundColor: GFColors.PRIMARY,
              ),
              child: dateTimeController.text.isEmpty
                  ? const Text(
                      "Sélectionner",
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.bold),
                    )
                  : Text(
                      dateTimeController.text,
                      style: const TextStyle(
                          fontSize: FontSize.xMedium, color: AppColors.white),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GFColors.PRIMARY,
                ),
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
                      color: AppColors.white,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.bold,
                    )))
          ],
        ),
      ),
    );
  }
}
