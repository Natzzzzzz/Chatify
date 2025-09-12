import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.senderID,
    required super.type,
    required super.content,
    required super.sentTime,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    MessageType messageType;
    switch (json["type"]) {
      case "text":
        messageType = MessageType.TEXT;
        break;
      case "image":
        messageType = MessageType.IMAGE;
        break;
      default:
        messageType = MessageType.UNKNOWN;
    }

    return ChatMessageModel(
      senderID: json["sender_id"],
      type: messageType,
      content: json["content"],
      sentTime: (json["sent_time"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    String messageType;
    switch (type) {
      case MessageType.TEXT:
        messageType = "text";
        break;
      case MessageType.IMAGE:
        messageType = "image";
        break;
      default:
        messageType = "unknown";
    }

    return {
      "sender_id": senderID,
      "type": messageType,
      "content": content,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}
