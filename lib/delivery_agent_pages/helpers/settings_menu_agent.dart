import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/heading_text.dart';

class SettingsMenuItemsAgent extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const SettingsMenuItemsAgent({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      // Your chosen background color
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Icon(
                      icon,
                      color: Colors.grey[700],
                      size: 20,
                    )),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  title,
                  style: nunitoSansStyle.copyWith(
                      color: Colors.grey[700], fontSize: 16.0),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenuWithIconItems extends StatelessWidget {
  final IconData icon;
  final IconData buttonIcon;
  final String title;
  final String buttonText;
  final VoidCallback onTap;
  const SettingsMenuWithIconItems({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.buttonIcon,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeClass.facebookBlue
                          .withOpacity(0.09), // Your chosen background color
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Icon(
                      icon,
                      size: 20,
                    )),
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                HeadingText(title: title)
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  color: ThemeClass.facebookBlue
                      .withOpacity(0.09), // Your chosen background color
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      buttonIcon,
                      size: 14,
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      buttonText,
                      style: nunitoSansStyle.copyWith(
                        color: ThemeClass.facebookBlue,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
