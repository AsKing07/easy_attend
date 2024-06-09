// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_dashboard.dart';
import 'package:easy_attend/Screens/etudiant/giveQRattendance.dart';
import 'package:easy_attend/Screens/etudiant/makeAquery.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        text: 'Paramètres',
        icon: Icons.settings,
        tap: SettingsScreen(
          nom: "student",
        )),
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
      drawer: GFDrawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GFDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.secondaryColor),
              currentAccountPicture: const GFAvatar(
                radius: 80.0,
                backgroundImage: AssetImage("assets/admin.jpg"),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.medium,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.black),
              title: const Text('Visiter la version Web'),
              onTap: () {
                //lien de l'application pour EventOs Partenaires

                launchUrl(Uri.https('https://easyattend.alwaysdata.net/'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy, color: Colors.black),
              title: const Text('Politiques de Confidentialité'),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => Policy()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.black),
              title: const Text('A Propos de l\'Application'),
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Se Déconnecter'),
              onTap: () async {
                auth_methods_admin().logUserOut(context);
              },
            ),
          ],
        ),
      ),
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
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.query_stats),
            title: const Text('Requête'),
            activeColor: Colors.green,
          ),
          BottomNavyBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              title: const Text('Présence'),
              activeColor: Colors.orange),
          BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Compte'),
              activeColor: Colors.black),
        ],
      ),
    );
  }
}
