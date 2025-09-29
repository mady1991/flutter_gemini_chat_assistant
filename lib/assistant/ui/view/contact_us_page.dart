import 'package:flutter/material.dart';

import '../../utils/wdg_app_bar_view.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarView(context: context, title: 'contact us'.toUpperCase()),
      body: const Center(child: Text('Contact Us Page')),
    );
  }
}
