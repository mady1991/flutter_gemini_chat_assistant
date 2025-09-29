import 'package:flutter/material.dart';
import 'package:static_chat_assitant/assistant/ui/view/build_category.dart';
import 'package:static_chat_assitant/assistant/ui/view/build_category_issues.dart';
import 'package:static_chat_assitant/assistant/ui/view/build_chat_bubble.dart';
import 'package:static_chat_assitant/assistant/ui/view/build_more_option.dart';
import 'package:static_chat_assitant/assistant/ui/view/build_suggestions.dart';
import 'package:static_chat_assitant/assistant/ui/app_assistant.dart';

import '../models/Issue.dart';

class AssistantChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;
  final bool isSuggestion;
  final bool mainCategoryView;

  // 🔥 NEW
  final bool isCategoryView;
  final Map<String, List<Issue>>? categoryList;
  final String? selectedCategory;
  final List<Issue>? suggestions;
  final List<String>? images;
  final String? action;

  const AssistantChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.isSuggestion = false,
    this.isCategoryView = false,
    this.mainCategoryView = false,
    this.categoryList,
    this.selectedCategory,
    this.suggestions,
    this.images,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    // ---------------- CATEGORY VIEW ----------------
    if (isCategoryView) {
      if (selectedCategory == null) {
        // show categories
        return buildCategories(context);
      } else {
        // show issues inside a category
        return buildCategoryIssues(context, selectedCategory!, categoryList);
      }
    }

    // ---------------- SUGGESTIONS ----------------
    if (isSuggestion && suggestions != null) {
      return buildSuggestions(context, suggestions);
    }

    // ---------------- MORE OPTIONS ----------------
    if (text == "moreoptions") {
      //show more options
      return buildMoreOptions(context);
    }

    // ---------------- RAISE TICKET FORM ----------------
    if (text == "form") {
      return context
                  .findAncestorStateOfType<AppAssistantState>()
                  ?.showRaiseTicket ==
              true
          ? context
                  .findAncestorStateOfType<AppAssistantState>()
                  ?.raiseTicketWidget() ??
              const SizedBox()
          : const SizedBox();
    }

    // ---------------- NORMAL CHAT ----------------
    return ChatBubble(
        isUser: isUser,
        isTyping: isTyping,
        text: text,
        images: images,
        action: action);
  }
}
