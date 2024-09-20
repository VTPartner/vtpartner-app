import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';

class HeadingText extends StatefulWidget {
  const HeadingText({super.key, required this.title});
  final String title;

  @override
  State<HeadingText> createState() => _HeadingTextState();
}

class _HeadingTextState extends State<HeadingText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: nunitoSansStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: ThemeClass.backgroundColorDark,
          fontSize: 14.0),
          overflow: TextOverflow.ellipsis,
    );
  }
}
