import 'package:flutter/material.dart';

import '../utils/app_styles.dart';

class SmallText extends StatefulWidget {
  const SmallText({super.key, required this.text});
  final String text;

  @override
  State<SmallText> createState() => _SmallTextState();
}

class _SmallTextState extends State<SmallText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: nunitoSansStyle.copyWith(
        color: Colors.black,
        fontSize: 12.0,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
