import 'package:flutter/material.dart';

import 'con_fonts.dart';


class NoNetwork extends StatelessWidget {
  double? width;

  NoNetwork({this.width});

  @override
  Widget build(BuildContext context) {
    String _label = "No Network";
    String label = _label.isEmpty
        ? "You are offline"
        : _label;

    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      width: width ?? getDeviceWidth(context) * .7,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.FontBebasNeue,
          color: Colors.white,
          fontWeight: AppFonts.FontWeight_w500,
          letterSpacing: 0.8,
          fontSize: AppFonts.FontSize_15,
        ),
      ),
    );
  }
}


double getDeviceWidth(context) {
  return MediaQuery.of(context).size.width;
}
