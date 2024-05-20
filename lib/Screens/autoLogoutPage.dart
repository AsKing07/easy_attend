import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:flutter/material.dart';

class AutoLogout extends StatefulWidget {
  const AutoLogout({super.key});

  @override
  State<AutoLogout> createState() => _AutoLogoutState();
}

class _AutoLogoutState extends State<AutoLogout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            "Inactivité remarquée",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.medium,
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              AlertDialog(
                content: SizedBox(
                  height: 200,
                  width: 30.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      children: const <Widget>[
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Absence d'activité",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Vous avez été déconnecté suite à une période d'inactivité de plus de 5 minutes",
                          style: TextStyle(
                            fontSize: FontSize.medium,
                          ),
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    child: const Text(
                      "Reconnexion",
                      style: TextStyle(color: Colors.orange),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthPage()),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
