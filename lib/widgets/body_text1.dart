import 'package:flutter/material.dart';

import '../utils/app_styles.dart';

class BodyText1 extends StatefulWidget {
  const BodyText1({super.key, required this.text});
  final String text;

  @override
  State<BodyText1> createState() => _BodyText1State();
}

class _BodyText1State extends State<BodyText1> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: nunitoSansStyle.copyWith(color: Colors.grey, fontSize: 12.0),
      overflow: TextOverflow.ellipsis, // Adds ellipsis when text overflows
    maxLines: 1, // Limits the text to a single line
    );
  }
}
