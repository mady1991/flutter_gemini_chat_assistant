import 'package:flutter/material.dart';
import '../../models/Issue.dart';
import '../../utils/con_fonts.dart';
import '../../utils/utl_formatting.dart';
import '../app_assistant.dart';

Widget buildCategoryIssues(BuildContext context, String category, Map<String, List<Issue>>? categoryList) {
  final issues = categoryList![category] ?? [];
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📑 We found these issues in *$category*:",
          style: FormattingUtils.getTextStyle(
            color: Colors.black,
            fontSize: AppFonts.FontSize_15,
            fontWeight: AppFonts.FontWeight_bold,
            height: 1.3,
            fontFamily: AppFonts.FontDDINCondensed,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: [
            ...issues.map((issue) {
              return ActionChip(
                avatar: const Icon(Icons.error_outline,
                    color: Colors.black, size: 18),
                label: Text(
                  issue.title,
                  style: FormattingUtils.getTextStyle(
                    color: Colors.black,
                    fontSize: AppFonts.FontSize_14,
                    height: 1.3,
                    fontFamily: AppFonts.FontDDINCondensed,
                  ),
                ),
                backgroundColor: Colors.grey.shade200.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8.0), // Adjust this value
                ),
                onPressed: () {
                  context
                      .findAncestorStateOfType<AppAssistantState>()
                      ?.handleSuggestionTap(issue);
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.arrow_back_ios,
                  color: Colors.black, size: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Adjust this value
              ),
              label: Text(
                "Back to Categories",
                style: FormattingUtils.getTextStyle(
                  color: Colors.black,
                  fontSize: AppFonts.FontSize_14,
                  height: 1.3,
                  fontFamily: AppFonts.FontDDINCondensed,
                ),
              ),
              backgroundColor: Colors.blue,
              onPressed: () {
                context
                    .findAncestorStateOfType<AppAssistantState>()
                    ?.showCategories();
              },
            ),
          ],
        ),
      ],
    ),
  );
}
