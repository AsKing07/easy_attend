// ignore_for_file: use_build_context_synchronously, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/etudiant/MakeQuery/makeQueryMobile.dart';
import 'package:easy_attend/Screens/etudiant/MakeQuery/makeQueryWeb.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dialogs/dialogs/message_dialog.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MakeQuery extends StatefulWidget {
  const MakeQuery({super.key});

  @override
  State<MakeQuery> createState() => _MakeQueryState();
}

class _MakeQueryState extends State<MakeQuery> {
  late Map<String, dynamic> etudiant;
  bool dataIsLoaded = false;

  String dropdownValue = 'Selectionnez un type';

  String queryTypeFromDB = "Aucune requete trouvée";
  String querySubjectFromDB = "----";
  String queryFromDB = "Vous n'avez envoyé aucune requête";
  String queryStatusFromDB = "null";

  final TextEditingController _queryController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();

  List<String> type = [
    'Suppression de compte',
    'Demande de permission d\'absence',
    'Justification d\'absence',
    'Autre requête'
  ];

  void loadCurrentStudent() async {
    try {
      final x = await get_Data().loadCurrentStudentData();

      final dynamic query = await get_Data().getQueryById(x['uid'], context);

      setState(() {
        etudiant = x;
        if (query.isNotEmpty) {
          querySubjectFromDB = query['sujet'];
          queryTypeFromDB = query['type'];
          queryStatusFromDB = query["statut"];
          queryFromDB = query['details'];
        }
        dataIsLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les données. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    loadCurrentStudent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > 1200
        //Large screen
        ? const MakeQueryWeb()
        : const MakeQueryMobile();
  }
}
