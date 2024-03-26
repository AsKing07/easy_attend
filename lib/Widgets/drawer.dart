import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HelperDrawer extends StatefulWidget {
  List<MenuItems> items;
  Function changePage;
  String nom;
  HelperDrawer(
      {required this.items, required this.changePage, required this.nom});

  @override
  State<HelperDrawer> createState() => _HelperDrawerState();
}

class _HelperDrawerState extends State<HelperDrawer> {
  String name = "";
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final DocumentSnapshot x = await FirebaseFirestore.instance
        .collection(widget.nom.toLowerCase())
        .doc(user!.uid)
        .get();
    setState(() {
      if (x.exists) {
        name = '${x['nom']}  ${x['prenom']}';
      } else {
        name = widget.nom;
      }
    });
  }

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
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/admin.jpg"),
                    radius: 35.0,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.medium,
                      color: Colors.white,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: GestureDetector(
                              onTap: () {
                                auth_methods_admin().logUserOut(context);
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: AppColors.textColor,
                                    size: 21,
                                  ),
                                  Text(
                                    "Deconnexion",
                                    style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: FontSize.small,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ))
                        ],
                      ),
                    ],
                  ))
            ],
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
              )),
        ],
      ),
    ),
  );
}
