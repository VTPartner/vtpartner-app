import 'package:flutter/material.dart';

import '../utils/app_styles.dart';

class DescriptionText extends StatefulWidget {
  const DescriptionText({super.key, required this.descriptionText});
  final String descriptionText;

  @override
  State<DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.descriptionText,
    style: nunitoSansStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 12.0,
    ),
    overflow: TextOverflow.ellipsis,);
  }
}