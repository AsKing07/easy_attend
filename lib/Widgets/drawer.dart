// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

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
  User? user = FirebaseAuth.instance.currentUser;

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
    http.Response response = await http.get(
      Uri.parse('$BACKEND_URL/api/${widget.nom.toLowerCase()}/${user!.uid}'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(response.body);
      setState(() {
        name = '${user['nom']}  ${user['prenom']}';
      });
    } else {
      setState(() {
        name = widget.nom;
      });
    }
  }
  // Future<void> _loadUserName() async {
  //   final DocumentSnapshot x = await FirebaseFirestore.instance
  //       .collection(widget.nom.toLowerCase())
  //       .doc(user!.uid)
  //       .get();

  //   setState(() {
  //     if (x.exists) {
  //       name = '${x['nom']}  ${x['prenom']}';
  //     } else {
  //       name = widget.nom;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: (ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.secondaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/admin.jpg"),
                    radius: 30.0,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
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
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
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
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: widget.items
                    .map((item) => menuItem(item, widget.changePage, context))
                    .toList(),
              ),
            ),
          ),
          Center(
            child: Text(
              'Version: ${widget.AppVersion}',
              style: const TextStyle(color: AppColors.textColor),
            ),
          )
        ],
      )),
    );
  }
}

Widget menuItem(MenuItems item, Function changePage, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      changePage(item);
    },
    child: Container(
      color:
          item.isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          children: [
            Expanded(
              child: Icon(
                item.icon,
                size: 21,
                color: AppColors.textColor,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.text,
                style: const TextStyle(
                    color: AppColors.textColor,
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
