import 'package:flutter/material.dart';

import '../../assistant/models/Issue.dart';

Widget buildCategoryIssues(
  List<Issue> issues,
  BuildContext context,
  void Function(Issue issue) handleIssueTap,
) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📑 We found these issues:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: [
            ...issues.map((issue) {
              return ActionChip(
                avatar: const Icon(
                  Icons.error_outline,
                  color: Colors.black,
                  size: 18,
                ),
                label: Text(issue.title),
                backgroundColor: Colors.green.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () => handleIssueTap(issue),
              );
            }),
          ],
        ),
      ],
    ),
  );
}
