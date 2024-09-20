import 'package:flutter/material.dart';

import '../themes/themes.dart';
import '../utils/app_styles.dart';

class MainHeadingText extends StatefulWidget {
  const MainHeadingText({super.key, required this.title});
  final String title;

  @override
  State<MainHeadingText> createState() => _MainheadingTextState();
}

class _MainheadingTextState extends State<MainHeadingText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: nunitoSansStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: ThemeClass.backgroundColorDark,
          fontSize: 20.0),
    );
  }
}
