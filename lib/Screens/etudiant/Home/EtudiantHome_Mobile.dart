// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_dashboard.dart';
import 'package:easy_attend/Screens/etudiant/GiveAttendance/giveQRattendance.dart';
import 'package:easy_attend/Screens/etudiant/MakeQuery/makeAquery.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtudiantHomeMobile extends StatefulWidget {
  const EtudiantHomeMobile({super.key});

  @override
  State<EtudiantHomeMobile> createState() => _EtudiantHomeMobileState();
}

class _EtudiantHomeMobileState extends State<EtudiantHomeMobile> {
  int _selectedIndex = 0;

  String name = "";
  String AppVersion = "N/A";

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      AppVersion = packageInfo.version;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    var utilisateur = json.decode(prefs.getString('user')!);

    name = '${utilisateur['nom']}  ${utilisateur['prenom']}';
  }

  MenuItems currentPage = MenuItems(
      text: 'Mon Dashboard',
      icon: Icons.dashboard_outlined,
      tap: const EtudiantDashboard(),
      isSelected: true);
  List<MenuItems> items = [
    MenuItems(
        text: 'Mon Dashboard',
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
        text: 'Paramètres', icon: Icons.settings, tap: const SettingsScreen()),
  ];

  @override
  void initState() {
    _loadUserName();
    _getAppVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentPage = Provider.of<PageModelStud>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          currentPage.currentPage.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: currentPage.currentPage.tap,
      bottomNavigationBar: BottomNavyBar(
        // Barre de navigation inférieure

        selectedIndex: _selectedIndex,
        showElevation: true,

        curve: Curves.ease, // use this to remove appBar's elevation
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          currentPage.updatePage(items[_selectedIndex]);
        },

        items: [
          // Les éléments de la barre de navigation inférieure

          BottomNavyBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            activeColor: AppColors.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.query_stats),
            title: const Text('Requête'),
            activeColor: AppColors.secondaryColor,
          ),
          BottomNavyBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              title: const Text('Présence'),
              activeColor: AppColors.secondaryColor),
          BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Compte'),
              activeColor: AppColors.secondaryColor),
        ],
      ),
    );
  }
}
