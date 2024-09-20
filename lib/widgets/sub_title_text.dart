import 'package:flutter/material.dart';

import '../themes/themes.dart';
import '../utils/app_styles.dart';

class SubTitleText extends StatefulWidget {
  const SubTitleText({super.key, required this.subTitle});
  final String subTitle;

  @override
  State<SubTitleText> createState() => _SubTitleTextState();
}

class _SubTitleTextState extends State<SubTitleText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.subTitle,
    style: nunitoSansStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontSize: 12.0
    ),);
  }
}