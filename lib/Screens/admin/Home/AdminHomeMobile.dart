import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/manageCourse.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/manageFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/manageProf.dart';
import 'package:easy_attend/Screens/admin/ManageQueries/manageQueries.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/manageStudent.dart';
import 'package:easy_attend/Screens/admin/Dashboard/admin_Dashboard.dart';
import 'package:easy_attend/Screens/admin/seeAttendance/listOfCourse.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/PageOnMaintenance.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeMobile extends StatefulWidget {
  const AdminHomeMobile({super.key});

  @override
  State<AdminHomeMobile> createState() => _AdminHomeMobileState();
}

class _AdminHomeMobileState extends State<AdminHomeMobile> {
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
      tap: const AdminDashboard(),
      isSelected: true);

  List<MenuItems> items = [
    MenuItems(
        text: 'Dashboard',
        icon: Icons.dashboard_outlined,
        tap: const AdminDashboard()),
    MenuItems(
        text: 'Filières', icon: Icons.school, tap: const ManageFilierePage()),
    MenuItems(
        text: 'Professeurs', icon: Icons.person_3, tap: const ManageProf()),
    MenuItems(
        text: 'Etudiants', icon: Icons.person, tap: const ManageStudentPage()),
    MenuItems(
        text: 'Cours',
        icon: Icons.settings_applications_outlined,
        tap: const ManageCoursePage()),
    MenuItems(
        text: 'Présences',
        icon: Icons.assignment_turned_in_sharp,
        tap: const listOfCourse()),
    MenuItems(
        text: 'Requêtes',
        icon: Icons.query_stats,
        tap: const ManageQueriesPage()),
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
        actions: [
          PopupMenuButton(
              color: AppColors.secondaryColor,
              itemBuilder: (context) => [
                    PopupMenuItem(
                        child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home),
                            onPressed: () {},
                            tooltip: "Dashboard",
                          ),
                          const Text(
                            "Dashboard",
                            style: TextStyle(color: AppColors.white),
                          )
                        ],
                      ),
                    )),
                    PopupMenuItem(
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 6;
                              });
                            },
                            child: Row(
                              children: [
                                IconButton(
                                    tooltip: "Requêtes",
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.query_stats_outlined)),
                                const Text("Requêtes",
                                    style: TextStyle(color: AppColors.white))
                              ],
                            ))),
                    PopupMenuItem(
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 8;
                              });
                            },
                            child: Row(
                              children: [
                                IconButton(
                                    tooltip: "Profil",
                                    onPressed: () {},
                                    icon: const Icon(Icons.person)),
                                const Text("Profil",
                                    style: TextStyle(color: AppColors.white))
                              ],
                            )))
                  ])
        ],
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
        selectedIndex: _selectedIndex - 1,
        showElevation: true,
        items: [
          // Les éléments de la barre de navigation inférieure

          // BottomNavyBarItem(
          //   icon: const Icon(Icons.dashboard_outlined),
          //   title: const Text('Dashboard'),
          //   activeColor: Colors.blue,
          // ),
          BottomNavyBarItem(
            icon: const Icon(Icons.school),
            title: const Text('Filières'),
            activeColor: AppColors.filiereColor,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_3),
            title: const Text('Professeurs'),
            activeColor: AppColors.profColor,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.people),
            title: const Text('Etudiants'),
            activeColor: AppColors.studColor,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.play_lesson),
            title: const Text('Cours'),
            activeColor: AppColors.courColor,
          ),
          // BottomNavyBarItem(
          //   icon: const Icon(Icons.query_stats),
          //   title: const Text('Requêtes'),
          //   activeColor: AppColors.studColor,
          // ),
          BottomNavyBarItem(
            icon: const Icon(Icons.assignment_turned_in_sharp),
            title: const Text('Présence'),
            activeColor: AppColors.courColor,
          ),
        ],
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index + 1;
          });
        },
      ),
    );
  }
}
