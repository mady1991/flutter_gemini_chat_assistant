import 'package:flutter/material.dart';

import '../../utils/con_fonts.dart';
import '../../utils/utl_formatting.dart';
import '../app_assistant.dart';

Widget buildCategories(BuildContext context) {
  final categories = [
    {
      "icon": Icons.notifications_active,
      "title": "Notifications",
      "subtitle": "Manage push alerts, sounds, and in-app messages."
    },
    {
      "icon": Icons.design_services,
      "title": "UI / UX",
      "subtitle": "Handle layout issues, dark mode, and display adjustments."
    },
    {
      "icon": Icons.payment,
      "title": "Payments",
      "subtitle": "Troubleshoot card, UPI, and refund related problems."
    },
    {
      "icon": Icons.wifi,
      "title": "Network",
      "subtitle": "Fix API errors, connection issues, and timeouts."
    },
    {
      "icon": Icons.account_circle,
      "title": "Account",
      "subtitle": "Manage login, email updates, and security settings."
    },
    {
      "icon": Icons.speed,
      "title": "Performance / Battery",
      "subtitle": "Resolve app slowness, lag, and excessive battery use."
    },
    {
      "icon": Icons.cloud_download,
      "title": "Downloads / Uploads",
      "subtitle": "Handle file transfer issues, pauses, or corrupt files."
    },
    {
      "icon": Icons.extension,
      "title": "Miscellaneous Edge Cases",
      "subtitle": "Other rare or complex issues not covered above."
    },
  ];

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please choose a category:",
          style: FormattingUtils.getTextStyle(
            color: Colors.black,
            fontSize: AppFonts.FontSize_16,
            fontWeight: AppFonts.FontWeight_bold,
            height: 1.3,
            fontFamily: AppFonts.FontDDINCondensed,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(categories.length, (index) {
            final item = categories[index];
            return InkWell(
              onTap: () => context
                  .findAncestorStateOfType<AppAssistantState>()
                  ?.showIssuesForCategory(item["title"] as String),
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
                              item["title"].toString().toUpperCase() ,
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
                  if (index != categories.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      height: 15,
                      width: 1.5,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    ),
  );
}
