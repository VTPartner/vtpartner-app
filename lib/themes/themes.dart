import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vt_partner/utils/app_styles.dart';

class ThemeClass {

  
  // static const Color facebookBlue = Color(0xFF0042D9);
  static const Color facebookBlue = Color(0xFF0391E0);
  static const Color backgroundColor2 = Color(0xFF17203A);
  static const Color backgroundColorLight = Color(0xFFF2F6FF);
  // static const Color backgroundColorLightPink = Color(0xFFFEF1F2);
  static const Color backgroundColorLightPink = Colors.white;
  // static const Color backgroundColorLightPink = Color(0xFFF0F5FF);
  static const Color backgroundColorDark = Color(0xFF25254B);
  static const Color shadowColorLight = Color(0xFF4A5367);
  static const Color shadowColorDark = Colors.black;

  static ThemeData get themeData {
    // Set the status bar color globally
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Colors.grey[100], // Set the notification tray color to facebookBlue
      statusBarIconBrightness:
          Brightness.light, // Set the icons to be light-colored
    ));
    return ThemeData(
      // Define the overall color scheme

      colorScheme: ColorScheme(
        primary: facebookBlue, // Primary color
        secondary: facebookBlue, // Secondary color
        surface: Colors.white,
        background: Colors.grey[200]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: ThemeClass.backgroundColorLightPink,

      // App bar theme
      appBarTheme: const AppBarTheme(
        color: facebookBlue,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.black),
        // Uncomment and adjust as needed
        // textTheme: TextTheme(
        //   headlineLarge: TextStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //   ),
        // ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        // backgroundColor: facebookBlue,
        selectedItemColor: facebookBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),

      // Bottom app bar theme
      bottomAppBarTheme: const BottomAppBarTheme(
        color: facebookBlue,
        elevation: 8,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: facebookBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: nunitoSansStyle.copyWith(color: Colors.grey),
        labelStyle: nunitoSansStyle.copyWith(color: facebookBlue),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: facebookBlue,
        size: 24,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: const TextStyle(
            fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
        displayMedium: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        headlineLarge: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        headlineSmall: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        titleMedium: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        titleSmall: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: const TextStyle(fontSize: 16, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
        bodySmall: TextStyle(fontSize: 12, color: Colors.grey[600]),
        labelLarge: TextStyle(fontSize: 16, color: facebookBlue),
        labelMedium: TextStyle(fontSize: 14, color: facebookBlue),
        labelSmall: TextStyle(fontSize: 12, color: facebookBlue),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),

      // Define primary color
      primaryColor: facebookBlue,

      // Text selection theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: facebookBlue,
        selectionColor: facebookBlue.withOpacity(0.3),
        selectionHandleColor: facebookBlue,
      ),
   
   
    );


    
  }


}




// const Color primaryColor = Color(0xFF087F23);
const Color primaryColor = Color(0xFF0391E0);
const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;
const Color greyColor = Color(0xFF949494);
const Color lightGreyColor = Color(0xFFE6E6E6);
const Color greyShade3 = Color(0xFFB7B7B7);
const Color greyShade2 = Color(0xFFD2D2D2);
const Color secondaryColor = Color(0xFF3F3D56);
const Color redColor = Color(0xFFFF0000);
const Color greyF0Color = Color(0xFFF0F0F0);
const Color yellowColor = Color(0xFFFFAC33);

const double fixPadding = 10.0;

const SizedBox heightSpace = SizedBox(height: fixPadding);

const SizedBox height5Space = SizedBox(height: 5.0);

const SizedBox widthSpace = SizedBox(width: fixPadding);

const SizedBox width5Space = SizedBox(width: 5.0);

SizedBox heightBox(double height) {
  return SizedBox(height: height);
}

SizedBox widthBox(double width) {
  return SizedBox(width: width);
}

List<BoxShadow> buttonShadow = [
  BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6)),
  BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, -6))
];

const TextStyle rasa24BoldPrimary = TextStyle(
    letterSpacing: 3,
    fontFamily: "Rasa",
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor);

const TextStyle appBarStyle = TextStyle(fontWeight: FontWeight.w800);

const TextStyle extrabold20Black =
    TextStyle(fontWeight: FontWeight.w800, color: blackColor, fontSize: 20);

const TextStyle extrabold18White =
    TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: whiteColor);

const TextStyle semibold12Grey =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: greyColor);

const TextStyle semibold12White =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: whiteColor);

const TextStyle semibold15White =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: whiteColor);

const TextStyle semibold14Grey =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: greyColor);

const TextStyle semibold10Grey =
    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: greyColor);

const TextStyle semibold15Grey =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: greyColor);

const TextStyle semibold16Grey =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: greyColor);

const TextStyle semibold14Black =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold10Black =
    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold12Black =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold15Black =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold16Black =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold17Black =
    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold18Black =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle bold12Grey =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: greyColor);

const TextStyle bold20Black =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: blackColor);

const TextStyle bold16Black =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: blackColor);

const TextStyle bold18White =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: whiteColor);



const TextStyle bold12Primary =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor);

const TextStyle bold16Primary =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primaryColor);

const TextStyle bold18Primary =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor);

const TextStyle bold10White =
    TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: whiteColor);

const TextStyle bold12White =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: whiteColor);

const TextStyle bold13White =
    TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: whiteColor);

const TextStyle bold15White =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: whiteColor);

const TextStyle bold16White =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: whiteColor);

const TextStyle bold16Grey =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: greyColor);

const TextStyle bold16Red =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: redColor);

const TextStyle bold15Black =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: blackColor);

const TextStyle bold17Black =
    TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: blackColor);

const TextStyle bold18Black =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: blackColor);

const TextStyle bold14Primary =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryColor);

const TextStyle bold15Primary =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryColor);

const TextStyle regular13Grey =
    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: greyColor);

const TextStyle regular14Grey =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: greyColor);

const TextStyle regular16Grey =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: greyColor);

const TextStyle regular12Grey =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: greyColor);

const TextStyle regular15Grey =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: greyColor);

const TextStyle regular8White =
    TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: whiteColor);

const TextStyle regular14White =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: whiteColor);

const TextStyle regular16Black =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: blackColor);

const TextStyle semibold18Grey3 =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: greyShade3);

const TextStyle semibold18black =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold15black =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: blackColor);

const TextStyle semibold16black =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blackColor);