import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConst {
  static const kPrimaryColor = Color(0xFF0196FE);
  static const kButtonColor = Color(0xffff395c);
  static const kButtonOtherColor = Color(0xffde8989);
  static const kPrimaryLightColor = Color(0xFFffffff);
  static const kBotChatColor = Color(0xFFEAEAEC);
  static const kGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xffff395c), Color(0xffde8989)],
  );

  static const kTextColor = Color(0xFF000000);
  static const kSubTextColor = Color(0xFF5b5b5b);
  static const double kRadius = 15;

  static const String defaultUrlAddress =
      "https://previews.123rf.com/images/seita/seita1706/seita170600015/81138383-flat-design-welcome-to-vietnam-icons-and-landmarks-vector.jpg";

  static const double kFontSize = 16;
  static const double kSubFontSize = 13;

  static TextStyle style(double size, Color color, {FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.roboto(fontSize: size, color: color, fontWeight: fontWeight, letterSpacing: 0.2);
  }

  static const Map<String, String> typeHouse = {
    "APARTMENT": "Chung cư",
    "HOUSE_LAND": "Nhà nguyên căn",
    "BEDSIT": "Phòng trọ",
  };
}
