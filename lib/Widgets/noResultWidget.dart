// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoResultWidget extends StatefulWidget {
  const NoResultWidget({super.key});

  @override
  State<NoResultWidget> createState() => _NoResultWidgetState();
}

class _NoResultWidgetState extends State<NoResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset('assets/search.svg',
                    semanticsLabel: 'Nothing found'),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 20),
          const Text("Pas de résultats 🥲")
        ],
      ),
    );
  }
}
