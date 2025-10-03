import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:static_chat_assitant/gen_ai/apis/api_service.dart';
import 'package:static_chat_assitant/hybrid/widget/buildCategoriesView.dart';
import 'package:static_chat_assitant/hybrid/widget/buildInputField.dart';
import 'package:static_chat_assitant/hybrid/widget/buildMessageBubble.dart';
import 'package:static_chat_assitant/hybrid/widget/buildTypingIndicator.dart';
import 'package:string_similarity/string_similarity.dart';

import '../assistant/models/Issue.dart';
import '../gen_ai/providers/chat_provider.dart';
import '../gen_ai/models/message.dart' as ai_message;

class HybridChatScreen extends StatefulWidget {
  const HybridChatScreen({super.key});

  @override
  State<HybridChatScreen> createState() => _HybridChatScreenState();
}

class _HybridChatScreenState extends State<HybridChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<Issue> _localIssues = [];
  bool _isLoading = false;
  int _localSearchAttempts = 0;
  bool _showTypingIndicator = false;
  Map<String, List<Issue>> _categoryList = {};
  bool _showCategories = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _addWelcomeMessage();
  }

  void _loadLocalData() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/app_full_issues.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> issuesJson = data['issues'];

      _localIssues = issuesJson
          .map<Issue>(
            (issue) => Issue(
              id: issue['id'],
              category: issue['category'],
              title: issue['title'],
              scenario: issue['scenario'],
              rootCause: issue['rootCause'],
              solution: issue['solution'],
              action: issue['action'],
              keywords: List<String>.from(issue['keywords']),
              imageList: issue['imageList'] != null
                  ? List<String>.from(issue['imageList'])
                  : null,
            ),
          )
          .toList();

      // Group issues by category
      _categoryList = _groupIssuesByCategory(_localIssues);
    } catch (e) {
      print('Error loading local data: $e');
    }
  }

  Map<String, List<Issue>> _groupIssuesByCategory(List<Issue> issues) {
    final Map<String, List<Issue>> grouped = {};
    for (var issue in issues) {
      if (!grouped.containsKey(issue.category)) {
        grouped[issue.category] = [];
      }
      grouped[issue.category]!.add(issue);
    }
    return grouped;
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.inChatMessages.add(
        ai_message.Message(
          messageId: '0',
          chatId: 'welcome',
          role: ai_message.Role.assistant,
          message: StringBuffer(
            "👋 Hello! I'm your Hybrid Assistant! 🤖\n\n"
            "I'll first check my local knowledge base 📚 for quick solutions, "
            "and if I don't find an answer, I'll use advanced AI to help you. ✨",
          ),
          imagesUrls: [],
          timeSent: DateTime.now(),
        ),
      );
      chatProvider.notifyListeners();
      _scrollToBottom();
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Add user message
    chatProvider.inChatMessages.add(
      ai_message.Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatProvider.currentChatId,
        role: ai_message.Role.user,
        message: StringBuffer(text),
        imagesUrls: [],
        timeSent: DateTime.now(),
      ),
    );

    _textController.clear();
    _focusNode.unfocus();
    chatProvider.notifyListeners();
    _scrollToBottom();

    setState(() {
      _isLoading = true;
      _showCategories = false;
    });

    // Step 1: Search in local database
    final localResult = _searchLocalIssues(text);

    if (localResult.isNotEmpty) {
      // Found in local database
      await Future.delayed(const Duration(milliseconds: 500));
      final issue = localResult.first;
      final response = _formatLocalResponse(issue);
      _addAssistantMessage(response, isLocal: true);
      _localSearchAttempts = 0;
    } else {
      _localSearchAttempts++;

      if (_localSearchAttempts <= 2) {
        // Try fuzzy search
        await Future.delayed(const Duration(milliseconds: 800));
        final fuzzyResults = _fuzzySearch(text);
        if (fuzzyResults.isNotEmpty) {
          final issue = fuzzyResults.first;
          final response = _formatFuzzyResponse(issue);
          _addAssistantMessage(response, isLocal: true);
          _localSearchAttempts = 0;
        } else {
          // Not found locally, use Gemini AI
          _showTypingIndicator = true;
          setState(() {});
          await _useGeminiAI(text, chatProvider);
          _showTypingIndicator = false;
        }
      } else {
        // Use Gemini AI directly after multiple local failures
        _showTypingIndicator = true;
        setState(() {});
        await _useGeminiAI(text, chatProvider);
        _showTypingIndicator = false;
      }
    }

    setState(() => _isLoading = false);
  }

  void _handleCategoryTap(String category) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Add user message for category selection
    chatProvider.inChatMessages.add(
      ai_message.Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatProvider.currentChatId,
        role: ai_message.Role.user,
        message: StringBuffer(category),
        imagesUrls: [],
        timeSent: DateTime.now(),
      ),
    );

    // Show issues for selected category
    _showIssuesForCategory(category);

    chatProvider.notifyListeners();
    _scrollToBottom();
    setState(() => _showCategories = false);
  }

  void _showIssuesForCategory(String category) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final issues = _categoryList[category] ?? [];

    String response = "📑 **We found these issues in *$category*:**\n\n";
    for (int i = 0; i < issues.length; i++) {
      response += "${i + 1}️⃣ ${issues[i].title}\n";
    }
    response += "\nTap on any issue to see the solution.";

    chatProvider.inChatMessages.add(
      ai_message.Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatProvider.currentChatId,
        role: ai_message.Role.assistant,
        message: StringBuffer(response),
        imagesUrls: [],
        timeSent: DateTime.now(),
        isCategoryIssues: true,
        categoryIssues: issues,
      ),
    );

    chatProvider.notifyListeners();
    _scrollToBottom();
  }

  void _handleIssueTap(Issue issue) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Add user message for issue selection
    chatProvider.inChatMessages.add(
      ai_message.Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatProvider.currentChatId,
        role: ai_message.Role.user,
        message: StringBuffer(issue.title),
        imagesUrls: [],
        timeSent: DateTime.now(),
      ),
    );

    // Show issue solution
    final response = _formatLocalResponse(issue);
    _addAssistantMessage(response, isLocal: true);

    chatProvider.notifyListeners();
    _scrollToBottom();
  }

  void _showMainCategories() {
    setState(() {
      _showCategories = true;
    });
    _scrollToBottom();
  }

  String _formatLocalResponse(Issue issue) {
    return """🎯 **${issue.title}**

📖 **Scenario:**
${issue.scenario}

🔍 **Root Cause:**
${issue.rootCause}

✅ **Solution:**
${issue.solution}

${issue.action != null && issue.action!.isNotEmpty ? '🚀 **Action:** ${issue.action!}' : ''}

💡 *Found in our knowledge base*""";
  }

  String _formatFuzzyResponse(Issue issue) {
    return """🔍 **Related Issue Found:** ${issue.title}

💡 **Solution:**
${issue.solution}

📚 *This might help with your query*""";
  }

  List<Issue> _searchLocalIssues(String query) {
    final lowerQuery = query.toLowerCase();
    return _localIssues.where((issue) {
      return issue.keywords.any(
            (keyword) => lowerQuery.contains(keyword.toLowerCase()),
          ) ||
          issue.title.toLowerCase().contains(lowerQuery) ||
          issue.scenario.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Issue> _fuzzySearch(String query) {
    final terms = query.toLowerCase().split(" ");
    final seenIds = <String>{};

    List<Issue> matchedIssues = _localIssues.where((issue) {
      final combinedText =
          "${issue.title} ${issue.scenario} ${issue.solution} ${issue.keywords.join(" ")}"
              .toLowerCase();
      final words = combinedText.split(" ");

      return terms.every((term) {
        final result = StringSimilarity.findBestMatch(term, words);
        return result.bestMatch.rating! >= 0.30;
      });
    }).toList();

    matchedIssues.sort((a, b) {
      final aContains = a.title.toLowerCase().contains(query.toLowerCase());
      final bContains = b.title.toLowerCase().contains(query.toLowerCase());

      if (aContains && !bContains) return -1;
      if (!aContains && bContains) return 1;
      return 0;
    });

    return matchedIssues
        .where((issue) => seenIds.add(issue.id))
        .take(3)
        .toList();
  }

  Future<void> _useGeminiAI(String query, ChatProvider chatProvider) async {
    try {
      // Show typing indicator
      _showTypingIndicator = true;
      setState(() {});

      // Initialize Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiService.apiKey,
      );

      final prompt = """The user asked: '$query'. 
I couldn't find this in my local knowledge base. 
Please provide a helpful, professional response to this app-related question.
Format the response with clear sections and use emojis to make it engaging.
Keep it concise but comprehensive.""";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _addAssistantMessage(
        response.text ??
            "❌ I apologize, but I couldn't generate a response. Please try again.",
        isLocal: false,
      );
    } catch (e) {
      _addAssistantMessage(
        "🌐 Connection Issue\n\n"
        "I encountered an error while connecting to the AI service. "
        "Please check your internet connection and try again.\n\n"
        "Error: ${e.toString()}",
        isLocal: false,
      );
    } finally {
      _showTypingIndicator = false;
      setState(() {});
    }
  }

  void _addAssistantMessage(String text, {bool isLocal = true}) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.inChatMessages.add(
      ai_message.Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatProvider.currentChatId,
        role: ai_message.Role.assistant,
        message: StringBuffer(text),
        imagesUrls: [],
        timeSent: DateTime.now(),
      ),
    );
    chatProvider.notifyListeners();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Hybrid Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _showMainCategories,
            tooltip: 'Show Categories',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        Theme.of(context).colorScheme.background,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        chatProvider.inChatMessages.length +
                        (_showTypingIndicator ? 1 : 0) +
                        (_showCategories ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_showCategories && index == 0) {
                        return buildCategoriesView(context,_handleCategoryTap);
                      }
                      if (_showTypingIndicator &&
                          index ==
                              (_showCategories ? 1 : 0) +
                                  chatProvider.inChatMessages.length) {
                        return buildTypingIndicator(context);
                      }
                      final messageIndex = index - (_showCategories ? 1 : 0);
                      final message = chatProvider.inChatMessages[messageIndex];
                      return buildMessageBubble(message,context,_handleIssueTap);
                    },
                  ),
                );
              },
            ),
          ),
          buildInputField(context,_textController,_focusNode,_isLoading,_sendMessage),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
