import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_dashboard.dart';
import 'package:easy_attend/Screens/etudiant/GiveAttendance/giveQRattendance.dart';
import 'package:easy_attend/Screens/etudiant/MakeQuery/makeAquery.dart';
import 'package:easy_attend/Screens/settings_screen.dart';
import 'package:easy_attend/Widgets/PageOnMaintenance.dart';
import 'package:easy_attend/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class EtudiantHomeWeb extends StatefulWidget {
  const EtudiantHomeWeb({super.key});

  @override
  State<EtudiantHomeWeb> createState() => _EtudiantHomeWebState();
}

class _EtudiantHomeWebState extends State<EtudiantHomeWeb> {
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
        text: 'Chat', icon: Icons.query_stats, tap: const MaintenancePage()),
    MenuItems(
        text: 'Scanner une présence',
        icon: Icons.qr_code_scanner,
        tap: const GiveQrAttendancePage()),
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
