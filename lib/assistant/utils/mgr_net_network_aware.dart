import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hlp_enumerations.dart';
import 'mgr_net_no_network.dart';


class NetworkAware extends StatelessWidget {
  final Widget child;
  final Widget? noNetworkChild;
  final Widget? networkStatusUnknownChild;
  final double? width;

  NetworkAware(
      {required this.child,
      this.noNetworkChild,
      this.networkStatusUnknownChild,
      this.width});

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == null) {
      return networkStatusUnknownChild ?? SizedBox();
    }
    return connectionStatus == ConnectivityStatus.Offline
        ? noNetworkChild ?? NoNetwork(width: width)
        : child;
  }
}
