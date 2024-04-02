import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/professeur/prof_Dashboard.dart';
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class ProfHome extends StatefulWidget {
  const ProfHome({super.key});

  @override
  State<ProfHome> createState() => _ProfHomeState();
}

class _ProfHomeState extends State<ProfHome> {
  MenuItems currentPage = MenuItems(
      text: 'Dashboard',
      icon: Icons.dashboard_outlined,
      tap: const ProfDashboard());
  List<MenuItems> items = [
    MenuItems(
        text: 'Dashboard',
        icon: Icons.dashboard_outlined,
        tap: const ProfDashboard()),
    // MenuItems(text: 'Paramètres', icon: Icons.settings, tap: teacherSetting()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HelperDrawer(
        items: items,
        changePage: (page) {
          setState(() {
            currentPage = page;
          });
        },
        nom: "Professeur",
      ),
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          currentPage.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: currentPage.tap,
    );
  }
}
