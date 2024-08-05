// ignore_for_file: file_names

import 'package:easy_attend/Screens/admin/Dashboard/admin_Dashboard.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_Dashboard.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuItems {
  String text;
  IconData? icon;
  Widget tap;
  bool isSelected;
  MenuItems(
      {required this.text,
      this.icon,
      required this.tap,
      this.isSelected = false});
}

class PageModelAdmin extends ChangeNotifier {
  MenuItems _currentPage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const AdminDashboard(),
    isSelected: true,
  );

  MenuItems get currentPage => _currentPage;

  void updatePage(MenuItems newPage) {
    _currentPage = newPage;

    notifyListeners();
  }
}

class PageModelProf extends ChangeNotifier {
  MenuItems _currentPage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const ProfDashboard(),
    isSelected: true,
  );
  final MenuItems basePage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const ProfDashboard(),
    isSelected: true,
  );

  MenuItems get currentPage => _currentPage;

  void updatePage(MenuItems newPage) {
    _currentPage = newPage;

    notifyListeners();
  }
}

class PageModelStud extends ChangeNotifier {
  MenuItems _currentPage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const EtudiantDashboard(),
    isSelected: true,
  );
  final MenuItems basePage = MenuItems(
    text: 'Dashboard',
    icon: Icons.dashboard_outlined,
    tap: const ProfDashboard(),
    isSelected: true,
  );

  MenuItems get currentPage => _currentPage;

  void updatePage(MenuItems newPage) {
    _currentPage = newPage;

    notifyListeners();
  }
}
