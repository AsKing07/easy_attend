// ignore_for_file: file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/manageCourse.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/manageFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/manageProf.dart';
import 'package:easy_attend/Screens/admin/ManageQueries/manageQueries.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/manageStudent.dart';
import 'package:easy_attend/Screens/admin/admin_Dashboard.dart';
import 'package:easy_attend/Screens/admin/seeAttendance/listOfCourse.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  MenuItems currentPage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const AdminDashboard(),
    isSelected: true, // Par défaut, la page d'accueil est sélectionnée
  );
  List<MenuItems> items = [
    MenuItems(
      text: 'Dashboard',
      icon: Icons.dashboard_outlined,
      tap: const AdminDashboard(),
    ),
    MenuItems(
        text: 'Gérer les filières',
        icon: Icons.school,
        tap: const ManageFilierePage()),
    MenuItems(
        text: 'Gérer les professeurs',
        icon: Icons.person_3,
        tap: const ManageProf()),
    MenuItems(
        text: 'Gérer les étudiants',
        icon: Icons.person,
        tap: const ManageStudentPage()),
    MenuItems(
        text: 'Gérer les Cours',
        icon: Icons.settings_applications_outlined,
        tap: const ManageCoursePage()),
    MenuItems(
        text: 'Gérer les requetes',
        icon: Icons.query_stats,
        tap: const ManageQueriesPage()),
    MenuItems(
        text: 'Gérer les présences',
        icon: Icons.assignment_turned_in_sharp,
        tap: const listOfCourse()),
    MenuItems(
        text: 'Paramètres',
        icon: Icons.settings,
        tap: SettingsScreen(
          nom: "Admin",
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
        nom: "Admin",
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
