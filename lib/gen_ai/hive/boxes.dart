
import 'package:hive/hive.dart';
import 'package:static_chat_assitant/gen_ai/hive/settings.dart';
import 'package:static_chat_assitant/gen_ai/hive/user_model.dart';

import '../constants/constants.dart';
import 'chat_history.dart';

class Boxes {
  // get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
