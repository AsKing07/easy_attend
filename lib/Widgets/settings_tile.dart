import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const SettingsTile(
      {Key? key,
      required this.color,
      required this.icon,
      required this.title,
      required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: color,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.chevron_right_outlined,
              color: AppColors.white,
            ),
          ),
        )
      ],
    );
  }
}
