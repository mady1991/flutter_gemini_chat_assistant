import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'con_fonts.dart';

class FormattingUtils {


  static TextStyle getTextStyle(
      {required Color color,
      required double fontSize,
      required double height,
      FontWeight fontWeight = FontWeight.normal,
      double letterSpacing = 1.3,
      String fontFamily = AppFonts.FontBebasNeue,
      TextDecoration textDecoration = TextDecoration.none}) {
    return TextStyle(
        fontSize: fontSize,
        height: height,
        color: color,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: textDecoration);
  }
}
