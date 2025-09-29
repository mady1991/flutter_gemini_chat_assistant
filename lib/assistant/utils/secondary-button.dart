import 'package:flutter/material.dart';
import 'package:static_chat_assitant/assistant/utils/primary-button.dart';

import 'con_fonts.dart';


Widget createSecondaryButton(
    {required BuildContext context,
    required String label,
    Widget? icon,
    VoidCallback? onPressed,
    isIconFirst = true,
    networkAware = true,
    buttonDisable = false,
    bool backGround = false,
    Color? borderColor,
    double? xMargin}) {
  EdgeInsetsGeometry horizontalMargin =
      EdgeInsets.symmetric(horizontal: xMargin != null ? xMargin : 20);
  Color buttonColor = buttonDisable
      ? Colors.white70
      : Colors.white;
  double buttonHeight = 45;
  RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(22),
    ),
    side: new BorderSide(color: borderColor ?? Colors.blue, width: 2.5),
  );
  Text buttonText = Text(
    label,
    style: TextStyle(
      //color: GlobalConfig.app_theme_base_color,
      color: Colors.black,
      letterSpacing: 1.3,
      fontSize: AppFonts.FontSize_18,
      fontWeight: FontWeight.normal,
      fontFamily: AppFonts.FontBebasNeue,
    ),
  );
  return createButton(
      context,
      icon,
      buttonDisable ? null : onPressed,
      horizontalMargin,
      buttonColor,
      buttonHeight,
      buttonShape,
      buttonText,
      isIconFirst,
      buttonBackgroundMember: backGround,
      networkAware: networkAware);
}
