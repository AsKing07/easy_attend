import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/PageOnMaintenance.dart';
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class ProfHomeWeb extends StatefulWidget {
  const ProfHomeWeb({super.key});

  @override
  State<ProfHomeWeb> createState() => _ProfHomeWebState();
}

class _ProfHomeWebState extends State<ProfHomeWeb> {
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
    MenuItems(
        text: 'Chat', icon: Icons.query_stats, tap: const MaintenancePage()),
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
