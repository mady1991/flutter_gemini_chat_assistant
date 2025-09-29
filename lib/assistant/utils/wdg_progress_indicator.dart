import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


createProgressIndicator({size = 30.0}) {
  return Center(
    child: SpinKitThreeBounce(
      size: size,
      color: Colors.blue,
    ),
  );
}
