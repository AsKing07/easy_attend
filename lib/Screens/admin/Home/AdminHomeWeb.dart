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
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class AdminHomeWeb extends StatefulWidget {
  const AdminHomeWeb({super.key});

  @override
  State<AdminHomeWeb> createState() => _AdminHomeWebState();
}

class _AdminHomeWebState extends State<AdminHomeWeb> {
  MenuItems currentPage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const AdminDashboard(),
    isSelected: true,
  );
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
        text: 'Analyser les requêtes',
        icon: Icons.query_stats,
        tap: const ManageQueriesPage()),
    MenuItems(
        text: 'Prendre les présences',
        icon: Icons.assignment_turned_in_sharp,
        tap: const listOfCourse()),
    MenuItems(
        text: 'EasyAttend Chat',
        icon: Icons.chat,
        tap: const MaintenancePage()),
    MenuItems(
        text: 'Paramètres', icon: Icons.settings, tap: const SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: HelperDrawer(
              items: items,
              changePage: (MenuItems page) {
                setState(() {
                  currentPage = page;
                  for (var item in items) {
                    item.isSelected = (item == page);
                  }
                });
              },
            ),
          ),
          Expanded(child: currentPage.tap)
        ],
      ),
    );
  }
}
