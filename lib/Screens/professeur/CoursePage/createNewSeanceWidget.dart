import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CreateNewSeanceWidget extends StatefulWidget {
  final dynamic course;
  const CreateNewSeanceWidget({super.key, required this.course});

  @override
  State<CreateNewSeanceWidget> createState() => _CreateNewSeanceWidgetState();
}

class _CreateNewSeanceWidgetState extends State<CreateNewSeanceWidget> {
  final dateTimeController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      is24HourMode: true,
    );

    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        dateTimeController.text = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
            .format(_dateTime.toLocal());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
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
        SizedBox(
          width: screenWidth > 1200 ? screenWidth / 3 : screenWidth / 1.5,
          child: InkWell(
            onTap: () async {
              _selectDate(context);
            },
            child: AbsorbPointer(
              child: TextFormField(
                  style: const TextStyle(
                      fontSize: 20, color: AppColors.secondaryColor),
                  controller: dateTimeController,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelStyle: GoogleFonts.cabin(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.textColor),
                      labelText: "Date & Heure",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: AppColors.textColor,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: AppColors.textColor,
                          width: 0.5,
                        ),
                      ),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(left: 25, right: 10),
                        child: IconTheme(
                          data: IconThemeData(color: AppColors.secondaryColor),
                          child: Icon(Icons.edit_calendar),
                        ),
                      ))),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GFButton(
            size: GFSize.LARGE,
            elevation: 6,
            color: AppColors.secondaryColor,
            child: Text("Créer la séance",
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: () async {
              if (dateTimeController.text.isEmpty) {
                Helper().ErrorMessage(context,
                    content: "Vous devez sélectionner la date et l'heure");
              } else {
                await set_Data()
                    .createSeance(widget.course, _dateTime.toLocal(), context);
              }
            })
      ],
    );
  }
}
