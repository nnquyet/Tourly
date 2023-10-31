import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConst {
  static const kPrimaryColor = Color(0xFF0196FE);
  static const kButtonColor = Color(0xffff395c);
  static const kPrimaryLightColor = Color(0xFFffffff);
  static const kBotChatColor = Color(0xFFEAEAEC);
  static const kGrayColor = Color(0xFFDCDCDC);
  static const kTransparentGrayColor = Color.fromRGBO(0, 0, 0, 0.5);
  static const kGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xffff395c), Color(0xffde8989)],
  );

  static const kTextColor = Color(0xFF000000);
  static const kSubTextColor = Color(0xFF5b5b5b);
  static const double kRadius = 15;

  static const String defaultUrlAddress =
      "https://firebasestorage.googleapis.com/v0/b/tourly-33e16.appspot.com/o/assets%2Fvietnam.jpeg?alt=media&token=bc6d9459-1b84-463f-8895-72d52c1b0d2d&_gl=1*dpxsn0*_ga*NjE3Nzk0ODQ2LjE2OTc3Mjk1MTg.*_ga_CW55HF8NVT*MTY5Nzc5NzIzNi41LjEuMTY5Nzc5ODA2Ni42MC4wLjA.";

  static const double kFontSize = 18;
  static const double kSubFontSize = 16;

  static TextStyle style(double size, Color color, {FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.roboto(fontSize: size, color: color, fontWeight: fontWeight, letterSpacing: 0.2);
  }

  static const Map<String, String> typeHouse = {
    "APARTMENT": "Chung cư",
    "HOUSE_LAND": "Nhà nguyên căn",
    "BEDSIT": "Phòng trọ",
  };
}
