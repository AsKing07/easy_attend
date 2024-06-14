// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/settings_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var utilisateur;
  bool dataIsLoaded = false;
  String name = "";
  String email = "";
  String role = "";
  String phone = "";
  String imageUrl = "assets/admin.jpg"; // Default image
  final BACKEND_URL = dotenv.env['API_URL'];
  final auth = FirebaseAuth.instance;

  Future<void> uploadPhoto(BuildContext context, XFile? pickedFile) async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    if (pickedFile != null) {
      String fileName = basename(pickedFile.path);
      String endpoint = role == "student"
          ? "student"
          : role == "prof"
              ? "prof"
              : "admin";

      // if (lookupMimeType(pickedFile.path) == "image/jpeg" ||
      //     lookupMimeType(pickedFile.path) == "image/jpg" ||
      //     lookupMimeType(pickedFile.path) == "image/png") {
      try {
        String contentType;
        if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          contentType = 'jpeg';
        } else if (fileName.toLowerCase().endsWith('.png')) {
          contentType = 'png';
        } else {
          contentType = "jpeg";
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '$BACKEND_URL/api/$endpoint/updatePhoto/${utilisateur['uid']}'),
        );

        if (kIsWeb) {
          // Web specific code to upload image
          var bytes = await pickedFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('image', bytes,
              filename: fileName,
              contentType: MediaType('image', contentType)));
        } else {
          // Mobile specific code to upload image
          File imageFile = File(pickedFile.path);
          request.files.add(http.MultipartFile('image',
              imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
              filename: fileName,
              contentType: MediaType('image', contentType)));
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await http.Response.fromStream(response);
          var jsonResponse = json.decode(responseData.body);
          await set_Data().UpdateCurrentUserData(context);
          setState(() {
            imageUrl = jsonResponse['imageUrl'];

            _loadUserName();
          });
          Navigator.pop(context);
          Helper()
              .succesMessage(context, content: 'Image téléchargée avec succès');
        } else {
          var responseData = await http.Response.fromStream(response);
          var jsonResponse = json.decode(responseData.body);
          print(jsonResponse);
          Navigator.pop(context);

          Helper().ErrorMessage(context,
              content: "Le téléchargement de l'image a échoué");
        }
      } catch (e) {
        Navigator.pop(context);

        kReleaseMode
            ? Helper().ErrorMessage(context,
                content: "Le téléchargement de l'image a échoué")
            : Helper().ErrorMessage(context,
                content: "Le téléchargement de l'image a échoué :$e");
      }
      //}
      //  else {
      //   Navigator.pop(context);
      //   Helper().ErrorMessage(context,
      //       content: "Seuls les fichiers jpeg et png sont acceptés");
      // }
    } else {
      Navigator.pop(context);

      Helper().ErrorMessage(context, content: "Aucune image sélectionnée");
    }
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var user = json.decode(prefs.getString('user')!);
      var userRole = prefs.getString('role')!;

      setState(() {
        name = '${user['nom']}  ${user['prenom']}';
        email = '${user['email']}';
        role = userRole;
        phone = user['phone'].toString();
        utilisateur = user;
        dataIsLoaded = true;
        imageUrl = user['image'] ?? imageUrl;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return !dataIsLoaded
        ? Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.secondaryColor, size: 100),
          )
        : Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Image
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: imageUrl.startsWith('http')
                                  ? NetworkImage(imageUrl)
                                  : AssetImage(imageUrl) as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: AppColors.secondaryColor,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    if (!kIsWeb) {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                          source: ImageSource.gallery);
                                      await uploadPhoto(context, pickedFile);
                                    } else {
                                      try {
                                        Uint8List? bytesFromPicker =
                                            await ImagePickerWeb
                                                .getImageAsBytes();
                                        XFile? xFile =
                                            XFile.fromData(bytesFromPicker!);

                                        await uploadPhoto(context, xFile);
                                      } catch (e) {
                                        kReleaseMode
                                            ? Helper().ErrorMessage(context,
                                                content:
                                                    "Erreur de téléchargement")
                                            : Helper().ErrorMessage(context,
                                                content:
                                                    "Erreur de téléchargement: $e");
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Paramètres',
                          style: TextStyle(
                              fontSize: FontSize.xxLarge,
                              letterSpacing: 2.0,
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          role == "student"
                              ? "Etudiant"
                              : role == "prof"
                                  ? "Professeur"
                                  : "Administrateur",
                          style: const TextStyle(
                              fontSize: FontSize.xLarge,
                              letterSpacing: 2.0,
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: FontSize.large,
                              letterSpacing: 1.5,
                              color: AppColors.textColor),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                              fontSize: FontSize.large,
                              letterSpacing: 1.5,
                              color: AppColors.textColor),
                        ),
                        Text(
                          phone,
                          style: const TextStyle(
                              fontSize: FontSize.large,
                              letterSpacing: 1.5,
                              color: AppColors.textColor),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SettingsTile(
                                  color: AppColors.secondaryColor,
                                  icon: Icons.lock,
                                  title: 'Changer le mot de passe',
                                  onTap: () {
                                    auth
                                        .sendPasswordResetEmail(
                                            email: utilisateur['email'])
                                        .then((value) {
                                      GFToast.showToast(
                                          'Un e-mail de réinitialisation a été envoyé à votre adresse e-mail. Consultez également vos spams.',
                                          context,
                                          toastDuration: 6);
                                    }).onError((error, stackTrace) {
                                      GFToast.showToast(
                                          error.toString(), context,
                                          toastDuration: 15);
                                    });
                                  },
                                ),
                                Divider(color: Colors.grey[400]),
                                SettingsTile(
                                  color: AppColors.secondaryColor,
                                  icon: Icons.person,
                                  title: 'Editer vos informations',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                SettingsTile(
                                  color: AppColors.secondaryColor,
                                  icon: Icons.open_in_browser_rounded,
                                  title: 'Visiter le site Web',
                                  onTap: () async {
                                    const url =
                                        'https://easyattend.alwaysdata.net/';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Impossible d\'ouvrir le lien $url';
                                    }
                                  },
                                ),
                                Divider(color: Colors.grey[400]),
                                SettingsTile(
                                  color: AppColors.secondaryColor,
                                  icon: Icons.policy,
                                  title: 'Politique de confidentialité',
                                  onTap: () {},
                                ),
                                Divider(color: Colors.grey[400]),
                                SettingsTile(
                                  color: AppColors.secondaryColor,
                                  icon: Icons.developer_board_rounded,
                                  title: 'A Propos du développeur',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (isSmallScreen) ...[
                          ElevatedButton(
                            onPressed: () async {
                              auth_methods_admin().logUserOut(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 15.0),
                            ),
                            child: const Text(
                              'Déconnexion',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
