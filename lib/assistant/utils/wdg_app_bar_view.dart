import 'package:flutter/material.dart';

import 'con_fonts.dart';

getAppBarView({
  required BuildContext context,
  var title,
  bool hideLeading = true,
  color = Colors.white,
  bool hasActions = false,
  String assetImage = "",
  VoidCallback? callback,
  IconData? icon,
  bool isWallet = false,
  double elevation = 0.0,
}) => AppBar(
  toolbarHeight: hasActions ? 70 : 55,
  centerTitle: true,
  shadowColor: color,
  elevation: hasActions ? 0 : elevation,
  backgroundColor: color,
  leading: hideLeading
      ? IconButton(
          onPressed: () {
              Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_sharp,
            color:  Colors.black,
          ),
        )
      : Icon(null),
  title: title is String
      ? Text(
          title,
          style: TextStyle(
            fontSize: AppFonts.FontSize_22,
            color: Colors.black,
            fontFamily: AppFonts.FontBebasNeue,
            letterSpacing: 1.5,
            fontWeight: FontWeight.normal,
          ),
        )
      : title,
  actions: hasActions
      ? [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: IconButton(
              iconSize: 45,
              icon: icon != null
                  ? Icon(
                      icon,
                      size: 28,
                      color: Colors.black,
                    )
                  : Image.asset(assetImage, width: 45, height: 45),
              onPressed: callback,
            ),
          ),
        ]
      : [],
);
