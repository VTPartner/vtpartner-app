import 'package:flutter/material.dart';

import '../themes/themes.dart';
import '../utils/app_styles.dart';

class TitleAppBarText extends StatefulWidget implements PreferredSizeWidget {
  const TitleAppBarText({super.key, required this.title});
  final String title;

  @override
  State<TitleAppBarText> createState() => _TitleAppBarTextState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Height of the AppBar
}

class _TitleAppBarTextState extends State<TitleAppBarText> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: robotoStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: ThemeClass.backgroundColorLight,
            fontSize: 20.0),
      ),
      centerTitle: true,
    );
  }
}
