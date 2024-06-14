import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/maintenance.json',
              // width: 600,
              height: isSmallScreen ? screenHeight / 4 : screenHeight / 1.5,
              fit: BoxFit.fill),
          AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              WavyAnimatedText('Bientôt disponible!',
                  textStyle: const TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge)),
              WavyAnimatedText("Soyez à l'écoute",
                  textStyle: const TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge)),
            ],
            isRepeatingAnimation: true,
          ),
        ],
      )),
    );
  }
}
