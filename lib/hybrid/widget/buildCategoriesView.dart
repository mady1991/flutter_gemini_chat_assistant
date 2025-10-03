
import 'package:flutter/material.dart';

Widget buildCategoriesView(BuildContext context, void Function(String category) handleCategoryTap) {
  final categories = [
    {
      "icon": Icons.notifications_active,
      "title": "Notifications",
      "subtitle": "Manage push alerts, sounds, and in-app messages.",
    },
    {
      "icon": Icons.design_services,
      "title": "UI / UX",
      "subtitle": "Handle layout issues, dark mode, and display adjustments.",
    },
    {
      "icon": Icons.payment,
      "title": "Payments",
      "subtitle": "Troubleshoot card, UPI, and refund related problems.",
    },
    {
      "icon": Icons.wifi,
      "title": "Network",
      "subtitle": "Fix API errors, connection issues, and timeouts.",
    },
    {
      "icon": Icons.account_circle,
      "title": "Account",
      "subtitle": "Manage login, email updates, and security settings.",
    },
    {
      "icon": Icons.speed,
      "title": "Performance / Battery",
      "subtitle": "Resolve app slowness, lag, and excessive battery use.",
    },
    {
      "icon": Icons.cloud_download,
      "title": "Downloads / Uploads",
      "subtitle": "Handle file transfer issues, pauses, or corrupt files.",
    },
    {
      "icon": Icons.extension,
      "title": "Miscellaneous Edge Cases",
      "subtitle": "Other rare or complex issues not covered above.",
    },
  ];

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please choose a category:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(categories.length, (index) {
            final item = categories[index];
            return InkWell(
              onTap: () => handleCategoryTap(item["title"] as String),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            item["icon"] as IconData,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"].toString().toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                fontSize: 15,
                                height: 1.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["subtitle"] as String,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 13,
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
                      color: Theme.of(context).dividerColor,
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