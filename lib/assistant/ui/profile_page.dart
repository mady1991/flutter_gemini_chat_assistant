import 'package:flutter/material.dart';

import '../utils/wdg_app_bar_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarView(context: context, title: 'Profile'.toUpperCase()),
      body: const Center(child: Text('Profile Page')),
    );
  }
}
