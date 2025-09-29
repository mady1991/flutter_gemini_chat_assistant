import 'package:flutter/material.dart';

import '../../utils/con_fonts.dart';
import '../../utils/utl_formatting.dart';
import '../app_assistant.dart';

Widget buildMoreOptions(BuildContext context) {
  final categories = [
    {
      "icon": Icons.support_agent,
      "title": "Contact Us",
      "action": "contact_us",
      "subtitle": "Get in touch with our support team for assistance."
    },
    {
      "icon": Icons.help_outline,
      "title": "FAQ",
      "action": "faq",
      "subtitle": "Find answers to the most frequently asked questions."
    },
    {
      "icon": Icons.format_align_center,
      "title": "Raise a request",
      "action": "form",
      "subtitle": "Submit a new request."
    }
  ];
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(categories.length, (index) {
            final item = categories[index];
            return InkWell(
              onTap: () => context
                  .findAncestorStateOfType<AppAssistantState>()
                  ?.moreOption(
                      item["title"] as String, item["action"] as String),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circle Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue, // border color
                            width: 2, // border thickness
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            item["icon"] as IconData,
                            color: Colors.black,
                            // same as border color
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title + Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"] as String,
                              style: FormattingUtils.getTextStyle(
                                color: Colors.black,
                                fontSize: AppFonts.FontSize_15,
                                height: 1.3,
                                fontWeight: AppFonts.FontWeight_bold,
                                fontFamily: AppFonts.FontDDINCondensed,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["subtitle"] as String,
                              style: FormattingUtils.getTextStyle(
                                color: Colors.grey[600]!,
                                fontSize: AppFonts.FontSize_13,
                                fontFamily: AppFonts.FontDDINCondensed,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ],
    ),
  );
}
