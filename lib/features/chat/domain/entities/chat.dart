import 'chat_user.dart';
import 'chat_message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  final List<ChatMessage> messages;

  const Chat({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  });

  /// Lấy danh sách recipients (ngoại trừ current user)
  List<ChatUser> get recipients {
    return members.where((u) => u.uid != currentUserUid).toList();
  }
}
