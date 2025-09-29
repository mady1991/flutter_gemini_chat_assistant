
import 'package:flutter/material.dart';
import '../../models/Issue.dart';
import '../../utils/con_fonts.dart';
import '../../utils/utl_formatting.dart';
import '../app_assistant.dart';

Widget buildSuggestions(BuildContext context, List<Issue>? suggestions) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Try asking about:",
          style: FormattingUtils.getTextStyle(
            color: Colors.black,
            fontSize: AppFonts.FontSize_15,
            fontWeight: AppFonts.FontWeight_bold,
            height: 1.3,
            fontFamily: AppFonts.FontDDINCondensed,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: suggestions!.map((suggestion) {
            return GestureDetector(
              onTap: () {
                context
                    .findAncestorStateOfType<AppAssistantState>()
                    ?.handleSuggestionTap(suggestion);
              },
              child: Chip(
                label: Text(
                  suggestion.title,
                  style: FormattingUtils.getTextStyle(
                    color: Colors.black,
                    fontSize: AppFonts.FontSize_14,
                    height: 1.3,
                    fontFamily: AppFonts.FontDDINCondensed,
                  ),
                ),
                backgroundColor: Colors.teal.withOpacity(0.1),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}