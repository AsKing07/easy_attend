// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:easy_attend/Screens/professeur/Home/ProfHomeMobile.dart';
import 'package:easy_attend/Screens/professeur/Home/ProfHomeWeb.dart';

import 'package:flutter/material.dart';

class ProfHome extends StatefulWidget {
  const ProfHome({super.key});

  @override
  State<ProfHome> createState() => _ProfHomeState();
}

class _ProfHomeState extends State<ProfHome> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const ProfHomeWeb()

//Mobile screen
        : const ProfHomeMobile();
  }
}
