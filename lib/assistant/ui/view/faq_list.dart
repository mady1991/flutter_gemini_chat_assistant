import 'package:flutter/material.dart';

import '../../utils/wdg_app_bar_view.dart';

class FaqList extends StatefulWidget {
  const FaqList({super.key});

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarView(context: context, title: 'FAQ'.toUpperCase()),
      body: const Center(child: Text('Faq list Page')),
    );
  }
}
