// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperDrawer extends StatefulWidget {
  List<MenuItems> items;
  Function changePage;
  String nom;
  String? AppVersion;
  HelperDrawer(
      {Key? key,
      required this.items,
      required this.changePage,
      required this.nom,
      String? AppVersion})
      : super(key: key) {
    this.AppVersion = AppVersion ?? "N/A";
  }

  @override
  State<HelperDrawer> createState() => _HelperDrawerState();
}

class _HelperDrawerState extends State<HelperDrawer> {
  final BACKEND_URL = dotenv.env['API_URL'];
  String name = "";
  // User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _loadUserName();
    _getAppVersion();
    super.initState();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      widget.AppVersion = packageInfo.version;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    var utilisateur = json.decode(prefs.getString('user')!);
    setState(() {
      name = '${utilisateur['nom']}  ${utilisateur['prenom']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GFDrawer(
        color: AppColors.secondaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFDrawerHeader(
                  closeButton: const Text(""),
                  centerAlign: true,
                  decoration: const BoxDecoration(
                      color: AppColors.secondaryColor,
                      border: Border(
                          bottom:
                              BorderSide(width: 3, color: AppColors.white))),
                  currentAccountPicture: const GFAvatar(
                    radius: 80.0,
                    backgroundImage: AssetImage("assets/admin.jpg"),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      InkWell(
                        onTap: () async {
                          auth_methods_admin().logUserOut(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppColors.white,
                              size: 21,
                            ),
                            Text(
                              "Deconnexion",
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: FontSize.small,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            ...widget.items
                .map((item) => menuItem(item, widget.changePage, context))
                .toList(),
            Center(
              child: Text(
                'Version: ${widget.AppVersion}',
                style: const TextStyle(color: AppColors.white),
              ),
            )
          ],
        ));
  }
}

Widget menuItem(MenuItems item, Function changePage, BuildContext context) {
  return GestureDetector(
    onTap: () {
      changePage(item);
    },
    child: Container(
      color:
          item.isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          children: [
            Expanded(
              child: Icon(
                item.icon,
                size: 21,
                color: AppColors.white,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.text,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
