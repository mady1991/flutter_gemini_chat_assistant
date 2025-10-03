import 'package:flutter/material.dart';
import 'package:static_chat_assitant/assistant/models/Issue.dart';

import '../../gen_ai/models/message.dart' as ai_message;
import '../utils.dart';
import 'buildCategoryIssues.dart';

Widget buildMessageBubble(
  ai_message.Message message,
  BuildContext context,
  void Function(Issue issue) handleIssueTap,
) {
  final isUser = message.role == ai_message.Role.user;
  final isLocal =
      message.message.toString().contains('💡') ||
      message.message.toString().contains('🎯') ||
      message.message.toString().contains('📚');

  // Check if this is a category issues message
  if (message.isCategoryIssues == true && message.categoryIssues != null) {
    return buildCategoryIssues(
      message.categoryIssues!,
      context,
      handleIssueTap,
    );
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            backgroundColor: isLocal ? Colors.green : Colors.purple,
            radius: 16,
            child: Icon(
              isLocal ? Icons.auto_awesome : Icons.smart_toy,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Text(
                  isLocal ? 'Local Assistant' : 'AI Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : isLocal
                      ? Colors.green.shade50
                      : Colors.purple.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 20 : 0),
                    topRight: Radius.circular(isUser ? 0 : 20),
                    bottomLeft: const Radius.circular(20),
                    bottomRight: const Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : isLocal
                        ? Colors.green.withOpacity(0.2)
                        : Colors.purple.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message.toString(),
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLocal
                              ? Colors.green.withOpacity(0.1)
                              : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isLocal ? '📚 Local Knowledge' : '🤖 AI Powered',
                          style: TextStyle(
                            fontSize: 10,
                            color: isLocal ? Colors.green : Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatTime(message.timeSent),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            radius: 16,
            child: const Icon(Icons.person, color: Colors.white, size: 14),
          ),
        ],
      ],
    ),
  );
}
