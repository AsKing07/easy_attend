// ignore_for_file: non_constant_identifier_names, file_names, prefer_typing_uninitialized_variables

import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard_Mobile.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard_Web.dart';

import 'package:flutter/material.dart';

class ProfDashboard extends StatefulWidget {
  const ProfDashboard({super.key});

  @override
  State<ProfDashboard> createState() => _ProfDashboardState();
}

class _ProfDashboardState extends State<ProfDashboard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1200
        ? const ProfDashboardWeb()
        : const ProfDashboardMobile();
  }
}
