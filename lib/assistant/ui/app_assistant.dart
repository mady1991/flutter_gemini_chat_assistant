import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:static_chat_assitant/assistant/ui/profile_page.dart';
import 'package:static_chat_assitant/assistant/ui/view/contact_us_page.dart';
import 'package:static_chat_assitant/assistant/ui/view/faq_list.dart';
import 'package:string_similarity/string_similarity.dart';

import '../models/Issue.dart';
import '../utils/con_fonts.dart';
import '../utils/wdg_app_bar_view.dart';
import 'assistant_chat_message.dart';
import 'view/form_widget.dart';

class AppAssistant extends StatefulWidget {


  AppAssistant({super.key}) {
  }

  @override
  AppAssistantState createState() => AppAssistantState();
}

class AppAssistantState extends State<AppAssistant> {
  final List<AssistantChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();


  List<Issue> _issues = [];
  bool textIsThere = false;
  bool isSuggestion = true;
  List<Issue> _suggestions = [];
  Map<String, List<Issue>> categoryList = {};

  int _dontUnderstandCounter = 0; // consecutive counter
  bool showRaiseTicket = false;
  bool mainMenuIcon = true;

  final Map<String, String> _greetings = {
    "hello": "Hello! How can I help you with your App issues today?",
    "hi": "Hi there! What can I assist you with regarding the App?",
    "good morning": "Good morning! How can I help you with your app issues?",
    "good afternoon":
        "Good afternoon! What issues are you facing with the App?",
    "good evening": "Good evening! How can I assist you with the App?",
    "good night":
        "Good night! If you have any issues with the App, I'm here to help.",
    "namaste": "Namaste! How can I assist you with your App concerns?",
    "hey": "Hey! What problems are you experiencing with the App?",
  };

  @override
  void initState() {
    super.initState();
    getAllData();
    showMainCategoryWithMessage(
        "Hello! I'm your App Assistant. I can help you troubleshoot issues with FacePass, tickets, and other app features. How can I help you today?",
        false);
  }

  void _addMessage(String text, bool isUser,
      {bool isTyping = false, images = null, action = null}) {
    setState(() {
      _messages.add(AssistantChatMessage(
          text: text,
          isUser: isUser,
          isTyping: isTyping,
          images: images,
          action: action));
    });
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

  void _showSuggestions() {
    setState(() {
      _messages.add(AssistantChatMessage(
        text: "",
        isUser: false,
        isSuggestion: isSuggestion,
        suggestions: _suggestions,
      ));
    });
    _scrollToBottom();
  }

  void handleSuggestionTap(Issue suggestion) {
    _textController.text = suggestion.title;
    _handleSubmitted(suggestion);
  }

  void _handleSubmitted(var data) {
    String text = "";
    String msg = "";
    if (data is String) {
      text = data;
      msg = data;
    } else {
      text = data.keywords[0];
      msg = data.title;
    }
    _messages.removeWhere((message) => message.isCategoryView);
    _messages.removeWhere((message) => message.text == "moreoptions");
    mainMenuIcon = true;

    if (text.trim().isEmpty) return;

    _textController.clear();
    _addMessage(msg, true);

    setState(() {
      isSuggestion = false;
      textIsThere = false;
      _messages.removeWhere((message) => message.isSuggestion);
    });

    final lowerText = text.toLowerCase();
    bool isGreeting = false;

    for (var greeting in _greetings.keys) {
      if (lowerText.contains(greeting)) {
        isGreeting = true;
        _addMessage(_greetings[greeting]!, false);
        break;
      }
    }

    if (!isGreeting) {
      _addMessage("", false, isTyping: true);

      Future.delayed(const Duration(milliseconds: 1000), () {
        _processMessage(text);
      });
    }
  }

  void _processMessage(String text) {
    setState(() {
      _messages.removeWhere((message) => message.isTyping);
    });

    String lowerText = text.toLowerCase().trim();
    List<Issue> matchedIssues = [];

    for (var issue in _issues) {
      for (var keyword in issue.keywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          matchedIssues.add(issue);
          break;
        }
      }
    }

    if (matchedIssues.isNotEmpty) {
      _dontUnderstandCounter = 0; // reset counter on match
      Issue issue = matchedIssues.first;
      String response = "I found this issue that might help:\n\n"
          "📱 *${issue.title}*\n\n\n"
          //"🔍 *Root Cause:*\n${issue.rootCause}\n\n"
          "✅ *Solution:*\n${issue.solution}";
      _addMessage(response, false,
          images: issue.imageList, action: issue.action);

      // if (matchedIssues.length > 1) {
      //   _addMessage(
      //       "I found ${matchedIssues.length} possible issues. Would you like to see more?",
      //       false);
      // }
    } else {
      //In case if user input not exactly matches with any issues but it contain in some Issues keywords
      // Show suggestions again after response
      _suggestions = searchPossibleIssues(lowerText);
      if (_suggestions.isNotEmpty && !isSuggestion) {
        isSuggestion = true;
        _dontUnderstandCounter = 0;
        _addMessage(
            "I've not found any issues that match '${lowerText}' "
            "But I found some possible issues that might help:",
            false);
        _showSuggestions();
      } else {
        _dontUnderstandCounter++;
        if (_dontUnderstandCounter >= 3) {
          _dontUnderstandCounter = 0;
          //showRaiseTicket = true;
          _addMessage(
              "I'm still having trouble understanding your issue. Here are a few options you can explore that might help:",
              false);
          _messages.add(AssistantChatMessage(
            text: "moreoptions",
            isUser: false,
          ));
        } else {
          _addMessage(
              "I'm not sure I understand. Could you describe your issue in different words? "
              "Try mentioning words like: internet, facepass, face, ticket, enrollment, etc.",
              false);
        }
      }
    }
  }

  List<Issue> searchPossibleIssues(String query) {
    final terms = query.toLowerCase().split(" ");
    final seenIds = <String>{};

    List<Issue> matchedIssues = _issues.where((issue) {
      final combinedText =
          "${issue.title} ${issue.scenario} ${issue.solution} ${issue.keywords.join(" ")}"
              .toLowerCase();
      final words = combinedText.split(" ");

      return terms.every((term) {
        final result = StringSimilarity.findBestMatch(term, words);
        return result.bestMatch.rating! >= 0.50;
      });
    }).toList();

    //  Sort: prioritize items whose title contains the query text
    matchedIssues.sort((a, b) {
      final aContains = a.title.toLowerCase().contains(query.toLowerCase());
      final bContains = b.title.toLowerCase().contains(query.toLowerCase());

      if (aContains && !bContains) return -1; // a comes first
      if (!aContains && bContains) return 1; // b comes first
      return 0; // keep relative order otherwise
    });

    //Removing duplicate issues && max 5 issues
    return matchedIssues
        .where((issue) => seenIds.add(issue.id))
        .take(5)
        .toList();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: getAppBarView(
          context: context,
          title: 'App Assistant'.toUpperCase()),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: mainMenuIcon,
            child: IconButton(
              icon: const Icon(
                Icons.category,
                color: Colors.black87,
              ),
              onPressed: () {
                showMainCategoryWithMessage("Main Categories", true);
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (text) {
                setState(() => textIsThere = text.isNotEmpty);
              },
              onSubmitted: _handleSubmitted,
              focusNode: _focusNode,
              style: TextStyle(
                fontFamily: AppFonts.FontDDINCondensed,
                fontSize: AppFonts.FontSize_18,
                color: Colors.black,
              ),
              decoration: const InputDecoration.collapsed(
                  hintText: "Type your issue here...",
                  hintStyle: TextStyle(
                    fontSize: AppFonts.FontSize_18,
                    color: Colors.grey,
                    fontFamily: AppFonts.FontDDINCondensed,
                  )),
            ),
          ),
          Visibility(
            //visible: textIsThere,
            visible: true,
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color:Colors.black54,
              ),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  void showMainCategoryWithMessage(String msg, bool assistant) {
    _addMessage(msg, assistant);
    Future.delayed(const Duration(seconds: 1), () {
      showCategories();
    });
  }

  void getAllData() async {
    String jsonString =
        await rootBundle.loadString('assets/app_full_issues.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> issuesJson = data['issues'];

    _issues = issuesJson
        .map<Issue>((issue) => Issue(
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
                : null))
        .toList();
    _suggestions = getRandomItems(_issues, 5);
    categoryList = groupIssuesByCategory(_issues);
  }

  List<T> getRandomItems<T>(List<T> items, int count) {
    final shuffled = List<T>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  Widget raiseTicketWidget() {
    return raiseTicketForm(showRaiseTicket, _addMessage);
  }

  void showCategories() {
    setState(() {
      mainMenuIcon = false;
      _messages.removeWhere((message) => message.isCategoryView);
      _messages.removeWhere((message) => message.text == "form");
      _messages.add(AssistantChatMessage(
        text: "",
        isUser: false,
        isCategoryView: true,
        mainCategoryView: true,
        categoryList: categoryList,
      ));
    });
    _scrollToBottom();
  }

  void showIssuesForCategory(String category) {
    setState(() {
      // remove any old category/issue messages
      mainMenuIcon = true;
      _messages.removeWhere((message) => message.isCategoryView);

      _messages.add(AssistantChatMessage(
        text: "",
        isUser: false,
        isCategoryView: true,
        mainCategoryView: false,
        categoryList: categoryList,
        selectedCategory: category,
      ));
    });
    _scrollToBottom();
  }

  void moreOption(String txt, String action) {
    setState(() {
      mainMenuIcon = true;
      _messages.removeWhere((message) => message.text == "moreoptions");
      _messages.add(AssistantChatMessage(
        text: txt,
        isUser: true,
      ));
    });
    _scrollToBottom();
    //performaction
    Future.delayed(const Duration(seconds: 1), () {
      performAction(action);
    });
  }

  void performAction(String action) {
    //performaction
    switch (action) {
      case "contact_us":
        showPage( ContactUsPage());
        break;
      case "faq":
        showPage( FaqList());
        break;
      case "form":
        setState(() {
          showRaiseTicket = true;
          _messages.add(AssistantChatMessage(
            text: "form",
            isUser: false,
          ));
        });
        _scrollToBottom();
        break;
      case "profile":
        showPage(ProfilePage());
        break;
    }
  }

  showPage( var page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void submitForm() {
    // Remove form and show success message in chat
    setState(() {
      showRaiseTicket = false;
      _messages.removeWhere((message) => message.text == "form");
      _addMessage(
          "✅ Your ticket has been successfully submitted. Our team will contact you soon.",
          false);
    });
    _scrollToBottom();
  }
}
