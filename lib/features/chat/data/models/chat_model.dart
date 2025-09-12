import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_user.dart';

class ChatModel extends Chat {
  ChatModel({
    required super.uid,
    required super.currentUserUid,
    required super.members,
    required super.messages,
    required super.activity,
    required super.group,
  });

  factory ChatModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required List<ChatUser> members,
    required List<ChatMessage> messages,
    required String currentUserUid,
  }) {
    return ChatModel(
      uid: id,
      currentUserUid: currentUserUid,
      members: members,
      messages: messages,
      activity: data["is_activity"] ?? false,
      group: data["is_group"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "is_activity": activity,
      "is_group": group,
      "members": members.map((m) => m.uid).toList(),
    };
  }
}
