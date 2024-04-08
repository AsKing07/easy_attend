// ignore_for_file: file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/etudiant/etudiant_dashboard.dart';
import 'package:easy_attend/Screens/etudiant/giveQRattendance.dart';
import 'package:easy_attend/Screens/etudiant/makeAquery.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class EtudiantHome extends StatefulWidget {
  const EtudiantHome({super.key});

  @override
  State<EtudiantHome> createState() => _EtudiantHomeState();
}

class _EtudiantHomeState extends State<EtudiantHome> {
  MenuItems currentPage = MenuItems(
      text: 'Dashboard',
      icon: Icons.dashboard_outlined,
      tap: const EtudiantDashboard(),
      isSelected: true);
  List<MenuItems> items = [
    MenuItems(
        text: 'Dashboard',
        icon: Icons.dashboard_outlined,
        tap: const EtudiantDashboard()),
    MenuItems(
        text: 'Faire une requete',
        icon: Icons.query_stats,
        tap: const MakeQuery()),
    MenuItems(
        text: 'Scanner une présence',
        icon: Icons.qr_code_scanner,
        tap: const GiveQrAttendancePage()),
    MenuItems(
        text: 'Paramètres',
        icon: Icons.settings,
        tap: SettingsScreen(
          nom: "Etudiant",
        )),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HelperDrawer(
        items: items,
        changePage: (MenuItems page) {
          setState(() {
            currentPage = page;
            for (var item in items) {
              item.isSelected = (item == page);
            }
          });
        },
        nom: "Etudiant",
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
