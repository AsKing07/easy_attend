// ignore_for_file: non_constant_identifier_names

import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/my_success_widget.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:flutter/material.dart';

class Helper {
  void show_custom_message(
      String message, double height, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningWidget(
            title: "Information", content: message, height: height);
      },
    );
  }

  void succesMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SuccessWidget(
            content: "L'opération a été un success!", height: 100);
      },
    );
  }

  void ErrorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Une erreur inconnue s'est produite!", height: 140);
      },
    );
  }

  void filiereExistanteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Une filière avec le même id existe déjà.", height: 160);
      },
    );
  }

  void notAuthorizedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content:
                "Désolé, vous n'êtes pas autorisé(e) à accéder à cette page.",
            height: 180);
      },
    );
  }

  //  affiche un message  invalide si un mauvais e-mail ou mdp est fourni
  void badCredential(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return myErrorWidget(
            content: "Veuillez vérifier vos informations de connexion.",
            height: 150);
      },
    );
  }
}
