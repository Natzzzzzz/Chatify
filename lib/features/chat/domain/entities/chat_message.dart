enum MessageType { TEXT, IMAGE, UNKNOWN }

class ChatMessage {
  final String senderID;
  final MessageType type;
  final String content;
  final DateTime sentTime;

  const ChatMessage({
    required this.senderID,
    required this.type,
    required this.content,
    required this.sentTime,
  });
}
