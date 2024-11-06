import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
const Color backColor = Color(0xFFf3f6ff);
const Color royalBlue = Color(0xff345afb) ;
const Color   royalGray = Color(0xff88888a); 
const Color whiteSmoke = Color(0xfff3f3f5);
class AppThemes {

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
   primaryColor:royalBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor:royalBlue,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme.copyWith(
            bodyLarge: const TextStyle(color: Colors.black),
            bodyMedium: const TextStyle(color: Colors.black54),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:royalBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.black),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
   primaryColor:royalBlue,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor:royalBlue,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(color: Colors.white),
            bodyMedium: const TextStyle(color: Colors.white60),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:royalBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.white),
    ),
  );
   static const Color accentColor = Color(0xFF5E9EFF);
  static const Color shadow = Color(0xFF4A5367);
  static const Color shadowDark = Color(0xFF000000);
  static const Color background = Color(0xFFF2F6FF);
  static const Color backgroundDark = Color(0xFF25254B);
  static const Color background2 = Color(0xFF17203A);
 
}
 TextStyle get lightGray10 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 10,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  ));
}
 TextStyle get lightGray16 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 18,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  ));
}
 TextStyle get buttonText {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 18,
    color: Colors.white ,   fontWeight: FontWeight.w600,
  ));
}

 TextStyle get boldTitle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 20,
    color : Colors.black ,   fontWeight: FontWeight.w600,
  ));
}
TextStyle get boldText {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 14,
    color : Colors.black ,   fontWeight: FontWeight.w600,
  ));
}


 TextStyle get lightGray14 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 16,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  ));
}

 TextStyle get addStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
    fontSize: 16,
    color: Colors.black54,
    fontWeight: FontWeight.w600,
  ));
}