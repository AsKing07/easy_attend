// ignore_for_file: must_be_immutable, camel_case_types

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class errorWidget extends StatefulWidget {
  errorWidget({super.key, required this.error});
  dynamic error;

  @override
  State<errorWidget> createState() => _errorWidgetState();
}

class _errorWidgetState extends State<errorWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_outlined,
            color: Colors.red,
            size: 50,
          ),
          Text(
            kReleaseMode
                ? 'Oups... quelque chose s\'est mal passé'
                : widget.error,
          ),
        ],
      ),
    );
  }
}
