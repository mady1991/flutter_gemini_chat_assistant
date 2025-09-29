import 'package:flutter/material.dart';

import 'con_fonts.dart';



const RoundedRectangleBorder defaultButtonShape =
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22)));
const double defaultButtonXMargin = 20;

Widget createPrimaryButton(
    {required BuildContext context,
    required String label,
    Widget? icon,
    VoidCallback? onPressed,
    double? xMargin,
    bool bare = false,
    bool isIconFirst = true,
    Color? ctaColor,
    double height = 48,
    TextStyle? textStyle,
    RoundedRectangleBorder buttonShape = defaultButtonShape,
    bool fullWidth = true,
    MainAxisAlignment? mainAxisAlignment, bool networkAware = true}) {
  EdgeInsetsGeometry horizontalMargin = EdgeInsets.symmetric(
      horizontal: xMargin != null ? xMargin : defaultButtonXMargin);
  Color buttonColor = ctaColor ?? Colors.blue;
  double buttonHeight = height;

  Text buttonText = Text(
    label,
    style: textStyle ??
        TextStyle(
          color:Colors.black,
          letterSpacing: 1.8,
          fontSize: AppFonts.FontSize_18,
          fontWeight: AppFonts.FontWeight_normal,
          fontFamily: AppFonts.FontBebasNeue,
        ),
    softWrap: true,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
  if (bare) {
    return ButtonTheme(
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: buttonColor,
          disabledForegroundColor: Colors.grey.shade50,
          shape: defaultButtonShape,
        ),
        // color: buttonColor,
        // disabledColor: GlobalConfig.app_theme_disabled_button_color,
        // height: height,
        // shape: buttonShape,
        onPressed: onPressed,
        child: buttonText,
      ),
    );
  }
  return createButton(context, icon, onPressed, horizontalMargin, buttonColor,
      buttonHeight, buttonShape, buttonText, isIconFirst,
      fullWidth: fullWidth, networkAware: networkAware);
}

Widget createButton(
    BuildContext context,
    Widget? icon,
    VoidCallback? onPressed,
    EdgeInsetsGeometry margin,
    Color color,
    double height,
    RoundedRectangleBorder shape,
    Text text,
    bool isIconFirst,
    {bool fullWidth = true,
    bool buttonBackgroundMember = false,
      bool networkAware = true}) {
  Widget button =  _createButton(margin, icon, height, color, shape, isIconFirst, text, onPressed, buttonBackgroundMember: buttonBackgroundMember);

  return fullWidth
      ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: button),
          ],
        )
      : button;
}

Widget _createButton(EdgeInsetsGeometry margin, Widget? icon, double height, Color color,
    RoundedRectangleBorder shape, bool isIconFirst, Text text, VoidCallback? onPressed, {bool buttonBackgroundMember = false}) {

  return Container(
    margin: margin,
    child: icon != null
        ? ButtonTheme(
      height: height,
      child: TextButton.icon(
        style: TextButton.styleFrom(
            disabledBackgroundColor:
            Colors.grey.shade50,
            // foregroundColor: color,
            backgroundColor: color,
            shape: shape),
        // color: color,
        // disabledColor: GlobalConfig.app_theme_disabled_button_color,
        icon: isIconFirst ? icon : text,
        // height: height,
        // shape: shape,
        onPressed: onPressed,
        label: isIconFirst ? text : icon,
      ),
    )
        : ButtonTheme(
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
            disabledForegroundColor: buttonBackgroundMember
                ? Colors.grey.shade200
                : Colors.grey.shade50,
            backgroundColor: color,
            shape: shape),
        // disabledColor: buttonBackgroundMember
        //     ? hexToColor('#F9F9F9')
        //     : GlobalConfig.app_theme_disabled_button_color,
        // color: color,
        // height: height,
        // shape: shape,
        onPressed: onPressed,
        child: text,
      ),
    ),
  );
}
