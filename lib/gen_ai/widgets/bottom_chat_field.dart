import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:static_chat_assitant/gen_ai/widgets/preview_images_widget.dart';

import '../providers/chat_provider.dart';
import '../utility/animated_dialog.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
    required this.darkTheme,
  });

  final ChatProvider chatProvider;
  final bool darkTheme;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();

  // Speech to text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  bool _speechAvailable = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _showVoiceUI = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    _recordingTimer?.cancel();
    _stopListening();
    super.dispose();
  }

  // Initialize speech to text
  void _initializeSpeech() async {
    _speech = stt.SpeechToText();

    bool available = await _speech.initialize(
      onStatus: (status) {
        log('Speech status: $status');
        if (status == 'done' && _isListening) {
          _stopListening();
        }
        if (status == 'listening') {
          setState(() {
            _showVoiceUI = true;
          });
        }
      },
      onError: (error) {
        log('Speech error: $error');
        _stopListening();
        _showErrorSnackbar('Speech recognition error: $error');
      },
    );

    setState(() {
      _speechAvailable = available;
    });

    if (!available) {
      _showErrorSnackbar('Speech recognition not available on this device');
    }
  }

  // Start listening for speech
  Future<void> _startListening() async {
    // Check and request microphone permission
    PermissionStatus permission = await Permission.microphone.request();

    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission is required for voice input');
      return;
    }

    if (!_speechAvailable) {
      _showErrorSnackbar('Speech recognition is not available');
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _recordingSeconds = 0;
      _showVoiceUI = true;
    });

    // Start recording timer
    _startRecordingTimer();

    // Start speech recognition
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            textController.text = _recognizedText;
            _stopListening();
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  // Stop listening
  void _stopListening() {
    _recordingTimer?.cancel();
    _speech.stop();
    setState(() {
      _isListening = false;
      _recordingSeconds = 0;
      _showVoiceUI = false;
    });

    // If we have recognized text, update the text controller
    if (_recognizedText.isNotEmpty && textController.text.isEmpty) {
      textController.text = _recognizedText;
    }
  }

  // Cancel listening without saving text
  void _cancelListening() {
    _recordingTimer?.cancel();
    _speech.cancel();
    setState(() {
      _isListening = false;
      _recordingSeconds = 0;
      _showVoiceUI = false;
      _recognizedText = '';
    });
  }

  // Start recording timer
  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds = timer.tick;
      });

      // Auto-stop after 30 seconds
      if (timer.tick >= 30) {
        _stopListening();
      }
    });
  }

  // Format seconds to MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sentMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages =
        widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;
    bool isLoading = widget.chatProvider.isLoading;
    bool hasText = textController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice recording overlay
          if (_showVoiceUI) _buildVoiceRecordingOverlay(),

          if (hasImages)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: const PreviewImagesWidget(),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Attachment Button
                _buildAttachmentButton(hasImages, isLoading),
                const SizedBox(width: 12),
                // Text Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: textFieldFocus,
                            controller: textController,
                            textInputAction: TextInputAction.send,
                            enabled: !isLoading && !_isListening,
                            maxLines: 5,
                            minLines: 1,
                            onChanged: (value) => setState(() {}),
                            onSubmitted: isLoading || _isListening
                                ? null
                                : (String value) {
                                    if (value.trim().isNotEmpty) {
                                      sendChatMessage(
                                        message: value.trim(),
                                        chatProvider: widget.chatProvider,
                                        isTextOnly: hasImages ? false : true,
                                      );
                                    }
                                  },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              hintText: _isListening
                                  ? 'Listening...'
                                  : 'Type a message...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),

                        // Mic Button - Show when no text or when listening
                        if (!hasText || _isListening)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildMicrophoneButton(isLoading),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send Button
                _buildSendButton(hasText, hasImages, isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingOverlay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated microphone icon with pulse animation
          _buildPulsingMicIcon(),

          const SizedBox(width: 12),

          // Recording time and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording... ${_formatTime(_recordingSeconds)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_recognizedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _recognizedText,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_recognizedText.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Speak now...',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Cancel button
              IconButton(
                onPressed: _cancelListening,
                icon: Icon(Icons.close, color: Colors.grey[600], size: 24),
                tooltip: 'Cancel',
              ),

              // Stop button
              IconButton(
                onPressed: _stopListening,
                icon: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                tooltip: 'Done',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingMicIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.3),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic, color: Colors.red, size: 24),
          ),
        );
      },
    );
  }

  Widget _buildMicrophoneButton(bool isLoading) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isListening
            ? Colors.red.withOpacity(0.2)
            : Colors.transparent,
        shape: BoxShape.circle,
        border: _isListening ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: IconButton(
        onPressed: isLoading
            ? null
            : () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
        icon: Icon(
          _isListening ? Icons.stop : Icons.mic_none,
          color: _isListening ? Colors.red : !widget.darkTheme
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor.withOpacity(0.3),
          size: 22,
        ),
        tooltip: _isListening ? 'Stop recording' : 'Start voice input',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildAttachmentButton(bool hasImages, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: hasImages
            ? Colors.red.withOpacity(0.1)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isLoading
            ? null
            : () {
                if (hasImages) {
                  showMyAnimatedDialog(
                    context: context,
                    title: 'Delete Images',
                    content: 'Are you sure you want to delete the images?',
                    actionText: 'Delete',
                    onActionPressed: (value) {
                      if (value) {
                        widget.chatProvider.setImagesFileList(listValue: []);
                      }
                    },
                  );
                } else {
                  pickImage();
                }
              },
        icon: Icon(
          hasImages ? CupertinoIcons.delete : CupertinoIcons.paperclip,
          color: hasImages ? Colors.red : !widget.darkTheme
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor.withOpacity(0.3),
          size: 22,
        ),
        tooltip: hasImages ? 'Delete images' : 'Attach images',
      ),
    );
  }

  Widget _buildSendButton(bool hasText, bool hasImages, bool isLoading) {
    final bool canSend = hasText || hasImages;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: canSend && !isLoading && !_isListening
            ? [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: isLoading || _isListening
              ? null
              : () {
                  if (canSend) {
                    sendChatMessage(
                      message: textController.text,
                      chatProvider: widget.chatProvider,
                      isTextOnly: hasImages ? false : true,
                    );
                  }
                },
          child: Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: canSend
                        ? !widget.darkTheme
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor.withOpacity(0.3)
                        : Colors.grey,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
