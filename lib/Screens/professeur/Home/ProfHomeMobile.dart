import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/PageOnMaintenance.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfHomeMobile extends StatefulWidget {
  const ProfHomeMobile({super.key});

  @override
  State<ProfHomeMobile> createState() => _ProfHomeMobileState();
}

class _ProfHomeMobileState extends State<ProfHomeMobile> {
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
      tap: const ProfDashboard(),
      isSelected: true);
  List<MenuItems> items = [
    MenuItems(
        text: 'Mon Dashboard',
        icon: Icons.dashboard_outlined,
        tap: const ProfDashboard()),
    MenuItems(text: 'Chat', icon: Icons.chat, tap: const MaintenancePage()),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          items[_selectedIndex].text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: items[_selectedIndex].tap,
      bottomNavigationBar: BottomNavyBar(
        // Barre de navigation inférieure

        selectedIndex: _selectedIndex,
        showElevation: true,

        curve: Curves.ease, // use this to remove appBar's elevation
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: [
          // Les éléments de la barre de navigation inférieure

          BottomNavyBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            activeColor: AppColors.secondaryColor,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.contact_support_rounded),
            title: const Text('Chat'),
            activeColor: AppColors.secondaryColor,
          ),
          BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Compte'),
              activeColor: AppColors.secondaryColor),
        ],
      ),
    );
  }
}
