
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/con_fonts.dart';
import '../../utils/secondary-button.dart';
import '../../utils/utl_formatting.dart';
import '../../utils/wdg_progress_indicator.dart';
import '../app_assistant.dart';

class ChatBubble extends StatefulWidget {
  final bool isUser;
  final bool isTyping;
  final String text;
  final List<String>? images;
  final String? action;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.isTyping,
    required this.text,
    this.images,
    this.action,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool pressOnce = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isUser)
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/ic_launcher.png'),
            ),
          if (widget.isUser) const SizedBox(width: 40.0),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: widget.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: widget.isUser
                          ? Colors.grey
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.isTyping
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    "Thinking...",
                                    style: FormattingUtils.getTextStyle(
                                      color: Colors.black,
                                      fontSize: AppFonts.FontSize_14,
                                      height: 1.3,
                                      fontWeight: AppFonts.FontWeight_bold,
                                      fontFamily: AppFonts.FontDDINCondensed,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                widget.text,
                                style: FormattingUtils.getTextStyle(
                                  color: widget.isUser
                                      ? Colors.white
                                      :Colors.black,
                                  fontSize: AppFonts.FontSize_14,
                                  height: 1.3,
                                  fontFamily: AppFonts.FontDDINCondensed,
                                ),
                              ),
                        if (widget.images != null &&
                            widget.images!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.images!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      checkNetworkImage(widget.images![index])
                                          ? CachedNetworkImage(
                                              height: 150,
                                              fit: BoxFit.fill,
                                              width: 200,
                                              imageUrl: widget.images![index],
                                              placeholder: (context, url) =>
                                                  createProgressIndicator(),
                                            )
                                          : Image.asset(
                                              widget.images![index],
                                              width: 150,
                                              height: 200,
                                              fit: BoxFit.fill,
                                            ),
                                );
                              },
                            ),
                          ),
                        ],
                        if (widget.action != null) ...[
                          const SizedBox(height: 19),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Center(
                              child: createSecondaryButton(
                                buttonDisable: pressOnce,
                                borderColor: Colors.blue,
                                context: context,
                                label: widget.action!.toUpperCase(),
                                onPressed: () {
                                  context
                                      .findAncestorStateOfType<
                                          AppAssistantState>()
                                      ?.moreOption(widget.action!.toUpperCase(),
                                          widget.action!);
                                  setState(() {
                                    pressOnce = true; // disable after press
                                  });
                                },
                                xMargin: 0,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  if (!widget.isTyping)
                    Text(
                      widget.isUser ? "You" : "App Assistant",
                      style: FormattingUtils.getTextStyle(
                        color: Colors.black,
                        fontSize: AppFonts.FontSize_14,
                        height: 1.3,
                        fontFamily: AppFonts.FontDDINCondensed,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.isUser)
            CircleAvatar(
              backgroundColor: Colors.black,
              child: Image.asset('assets/ic_my_profile.png'),
            ),
        ],
      ),
    );
  }

  bool checkNetworkImage(String url) =>
      url.startsWith('http') || url.startsWith('https');
}
