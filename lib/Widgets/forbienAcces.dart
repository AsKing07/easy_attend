import 'package:flutter/material.dart';

class ForbiddenAccess extends StatelessWidget {
  final String message;
  final VoidCallback onLoginRedirect;

  const ForbiddenAccess(
      {Key? key, required this.message, required this.onLoginRedirect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accès Refusé'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ferme la boîte de dialogue
          },
          child: const Text('Fermer'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Ferme la boîte de dialogue
            onLoginRedirect(); // Appelle la fonction pour rediriger vers la page de connexion
          },
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}
