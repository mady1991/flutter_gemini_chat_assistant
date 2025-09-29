// --- Raise Ticket Form ---

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/con_fonts.dart';
import '../../utils/secondary-button.dart';
import '../../utils/utl_formatting.dart';
import '../app_assistant.dart';

Widget raiseTicketForm(bool showRaiseTicket,
    void Function(String text, bool isUser, {bool isTyping}) _addMessage) {
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  emailController.text = "fake@mail.com";
  XFile? pickedImage;

  String? emailError;
  String? messageError;

  return StatefulBuilder(
    builder: (context, setState) {
      // Validation & submit
      Future<void> validateAndSubmit() async {
        final email = emailController.text.trim();
        final msg = messageController.text.trim();
        bool isValid = true;

        // Clear previous errors
        setState(() {
          emailError = null;
          messageError = null;
        });

        if (!RegExp(r"^[\w\-.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email)) {
          emailError = "Enter a valid email";
          isValid = false;
        }

        if (msg.isEmpty) {
          messageError = "Message cannot be empty";
          isValid = false;
        }

        if (!isValid) {
          setState(() {});
          return;
        }

        // Fire intent to send mail
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {
            'subject': 'YI App Support Ticket',
            'body': msg,
          },
        );
        await launchUrl(emailUri);
        context.findAncestorStateOfType<AppAssistantState>()?.submitForm();
      }

      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Raise a Ticket",
                style: FormattingUtils.getTextStyle(
                  color: Colors.black,
                  fontSize: AppFonts.FontSize_15,
                  fontWeight: AppFonts.FontWeight_bold,
                  height: 1.3,
                  fontFamily: AppFonts.FontDDINCondensed,
                )),
            const SizedBox(height: 10),

            // Email Field
            TextField(
              readOnly: true,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                if (emailError != null) {
                  setState(() => emailError = null);
                }
              },
              style: TextStyle(
                fontFamily: AppFonts.FontDDINCondensed,
                fontSize: AppFonts.FontSize_18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Your Email",
                labelStyle: TextStyle(
                  fontFamily: AppFonts.FontDDINCondensed,
                  fontSize: AppFonts.FontSize_16,
                  color: Colors.grey.shade50,
                ),
                errorText: emailError,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Message Field
            TextField(
              controller: messageController,
              keyboardType: TextInputType.text,
              maxLines: 4,
              onChanged: (_) {
                if (messageError != null) {
                  setState(() => messageError = null);
                }
              },
              style: TextStyle(
                fontFamily: AppFonts.FontDDINCondensed,
                fontSize: AppFonts.FontSize_18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: "Message",
                labelStyle: TextStyle(
                  fontFamily: AppFonts.FontDDINCondensed,
                  fontSize: AppFonts.FontSize_16,
                  color: Colors.grey.shade50,
                ),
                errorText: messageError,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 19),

            // Attach & Capture
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {
                          pickedImage = image;
                        });
                      },
                      icon: const Icon(Icons.attach_file),
                      label: Text("ATTACH",
                          style: FormattingUtils.getTextStyle(
                            color: Colors.black,
                            fontSize: AppFonts.FontSize_12,
                            fontWeight: AppFonts.FontWeight_bold,
                            height: 1.3,
                            fontFamily: AppFonts.FontDDINCondensed,
                          )),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        setState(() {
                          pickedImage = image;
                        });
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text("CAPTURE",
                          style: FormattingUtils.getTextStyle(
                            color: Colors.black,
                            fontSize: AppFonts.FontSize_12,
                            fontWeight: AppFonts.FontWeight_bold,
                            height: 1.3,
                            fontFamily: AppFonts.FontDDINCondensed,
                          )),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22))),
                    ),
                  ),
                ],
              ),
            ),
            if (pickedImage != null) Text("Selected: ${pickedImage!.name}"),

            const SizedBox(height: 19),

            // Submit
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Center(
                child: createSecondaryButton(
                    borderColor: Colors.blue,
                    context: context,
                    label: "SUBMIT",
                    onPressed: validateAndSubmit,
                    xMargin: 0),
              ),
            ),
          ],
        ),
      );
    },
  );
}
