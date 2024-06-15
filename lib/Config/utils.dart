// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';

class screenSize {
  // Fonction pour vérifier si l'appareil est un téléphone
  bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

// Fonction pour vérifier si l'appareil est une tablette
  bool isTablet(BuildContext context) {
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600 && shortestSide < 960;
  }

// Fonction pour vérifier si l'appareil est un grand écran
  bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 1200;
  }

  bool isAndroid() {
    return Platform.isAndroid;
  }

  bool isWeb() {
    return identical(0, 0.0);
  }
}
