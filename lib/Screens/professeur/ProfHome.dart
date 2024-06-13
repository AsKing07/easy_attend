// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/professeur/prof_Dashboard.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
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
      tap: const ProfDashboard(),
      isSelected: true);
  List<MenuItems> items = [
    MenuItems(
        text: 'Dashboard',
        icon: Icons.dashboard_outlined,
        tap: const ProfDashboard()),
    MenuItems(text: 'Paramètres', icon: Icons.settings, tap: SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        //Large screen
        ? Scaffold(
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
            body: Row(
              children: [
                Container(
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
                    nom: "Prof",
                  ),
                ),
                Expanded(child: currentPage.tap)
              ],
            ),
          )

//Small screen
        : Scaffold(
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
              nom: "Prof",
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
