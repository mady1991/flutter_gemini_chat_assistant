import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:provider/provider.dart';

import '../hive/boxes.dart';
import '../hive/settings.dart';
import '../providers/chat_provider.dart';
import '../utility/animated_dialog.dart';
import '../widgets/bottom_chat_field.dart';
import '../widgets/chat_messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
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
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        // auto scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            centerTitle: true,
            title: const Text('Chat with Gemini'),
            actions: [
              if (chatProvider.inChatMessages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.add),
                      onPressed: () async {
                        // show my animated dialog to start new chat
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Start New Chat',
                          content: 'Are you sure you want to start a new chat?',
                          actionText: 'Yes',
                          onActionPressed: (value) async {
                            if (value) {
                              // prepare chat room
                              await chatProvider.prepareChatRoom(
                                isNewChat: true,
                                chatID: '',
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Container(
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
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ChatMessages(
                              scrollController: _scrollController,
                              chatProvider: chatProvider,
                            ),
                          ),
                  ),

                  // input field
                  ValueListenableBuilder<Box<Settings>>(
                    valueListenable: Boxes.getSettings().listenable(),
                    builder: (context, box, child) {
                      if (box.isEmpty) {
                        return const SizedBox();
                      } else {
                        final settings = box.getAt(0);
                        return BottomChatField(
                          chatProvider: chatProvider,
                          darkTheme: settings!.isDarkTheme,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
