import 'package:flutter/material.dart';
import '../themes/themes.dart'; // Import your theme file
import '../utils/app_styles.dart'; // Import your styles file

class GlobalFilledButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color? colorName;

  const GlobalFilledButton({
    Key? key,
    required this.onTap,
    required this.label, this.colorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: colorName ?? ThemeClass.facebookBlue, // Button background color
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: robotoStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white, // Text color
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
