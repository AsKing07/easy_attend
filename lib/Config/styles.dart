import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';

// colors to use in app
class AppColors {
  static const Color primaryColor = Color(0xFF9DD1F1);
  static const Color secondaryColor = Color(0xFF508AA8);
  static const Color tertiaryColor = Color(0xFFC8E0F4);
  static const Color textColor = Color(0xFF031927);
  static const Color accentColor = Color(0xFFBA1200);
  static const Color backgroundColor = Color(0XFFf7f7f7);
  static const Color greenColor = Color.fromARGB(255, 73, 233, 28);
  static const Color redColor = Color.fromARGB(255, 240, 18, 18);

  static const Color profColor = Color.fromARGB(255, 115, 218, 12);
  static const Color filiereColor = Color.fromARGB(255, 0, 0, 0);
  static const Color studColor = Colors.orange;
  static const Color courColor = Color.fromARGB(255, 82, 171, 244);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFBA1200), Color(0xFF031927)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient secondaryGradient = RadialGradient(
    colors: [
      CupertinoColors.white,
      Color(0xFF508AA8),
    ],
    radius: 2.5,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFBA1200), Color(0xFFFF0000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

//FontSize
class FontSize {
  static const xSmall = 10.0;
  static const small = 12.0;
  static const medium = 14.0;
  static const xMedium = 16.0;
  static const large = 18.0;
  static const xLarge = 20.0;
  static const xxLarge = 22.0;
  static const xxxLarge = 40.0;
}
