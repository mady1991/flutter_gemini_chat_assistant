import '../../assistant/models/Issue.dart';

class Message {
  String messageId;
  String chatId;
  Role role;
  StringBuffer message;
  List<String> imagesUrls;
  DateTime timeSent;
  bool? isCategoryIssues;
  List<Issue>? categoryIssues;

  Message({
    required this.messageId,
    required this.chatId,
    required this.role,
    required this.message,
    required this.imagesUrls,
    required this.timeSent,
    this.isCategoryIssues = false,
    this.categoryIssues,
  });


  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role.index,
      'message': message.toString(),
      'imagesUrls': imagesUrls,
      'timeSent': timeSent.toIso8601String(),
      'isCategoryIssues': isCategoryIssues,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      chatId: map['chatId'],
      role: Role.values[map['role']],
      message: StringBuffer(map['message']),
      imagesUrls: List<String>.from(map['imagesUrls']),
      timeSent: DateTime.parse(map['timeSent']),
      isCategoryIssues: map['isCategoryIssues'] ?? false,

    );
  }

  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imagesUrls,
    DateTime? timeSent,
    bool? isCategoryIssues,
    List<Issue>? categoryIssues,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      message: message ?? this.message,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      timeSent: timeSent ?? this.timeSent,
      isCategoryIssues: isCategoryIssues ?? this.isCategoryIssues,
      categoryIssues: categoryIssues ?? this.categoryIssues,
    );
  }
}


enum Role {
  user,
  assistant,
}