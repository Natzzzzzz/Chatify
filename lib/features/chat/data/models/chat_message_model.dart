import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.chatId,
    required super.senderID,
    required super.type,
    super.text,
    super.fileUrl,
    super.fileName,
    super.fileSize,
    super.location,
    required super.sentTime,
    super.seenBy,
  });

  factory ChatMessageModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatMessageModel.fromJson(doc.id, data);
  }

  factory ChatMessageModel.fromJson(String id, Map<String, dynamic> json) {
    // map type string -> enum
    MessageType messageType;
    switch (json["type"]) {
      case "text":
        messageType = MessageType.TEXT;
        break;
      case "image":
        messageType = MessageType.IMAGE;
        break;
      case "file":
        messageType = MessageType.FILE;
        break;
      case "location":
        messageType = MessageType.LOCATION;
        break;
      case "system":
        messageType = MessageType.SYSTEM;
        break;
      default:
        messageType = MessageType.UNKNOWN;
    }

    // hỗ trợ cả schema cũ (sent_time) lẫn schema mới (sentAt)
    final sentField = json["sentAt"] ?? json["sent_time"];
    final sentTimestamp = sentField as Timestamp;

    // location: GeoPoint hoặc lat/lng cũ
    GeoPoint? location;
    if (json["location"] is GeoPoint) {
      location = json["location"];
    } else if (json["lat"] != null && json["lng"] != null) {
      location = GeoPoint(
        (json["lat"] as num).toDouble(),
        (json["lng"] as num).toDouble(),
      );
    }

    return ChatMessageModel(
      id: id,
      chatId: json["chatId"] ?? json["chat_id"] ?? "",
      senderID: json["senderId"] ?? json["sender_id"] ?? "",
      type: messageType,
      text: json["text"] ?? json["content"],
      fileUrl: json["fileUrl"],
      fileName: json["fileName"],
      fileSize: json["fileSize"],
      location: location,
      sentTime: sentTimestamp.toDate(),
      seenBy: (json["seenBy"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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
      case MessageType.FILE:
        messageType = "file";
        break;
      case MessageType.LOCATION:
        messageType = "location";
        break;
      case MessageType.SYSTEM:
        messageType = "system";
        break;
      default:
        messageType = "unknown";
    }

    return {
      "id": id,
      "chatId": chatId,
      "senderId": senderID,
      "type": messageType,
      "text": text,
      "fileUrl": fileUrl,
      "fileName": fileName,
      "fileSize": fileSize,
      "location": location,
      "sentAt": Timestamp.fromDate(sentTime),
      "seenBy": seenBy,
    };
  }

  factory ChatMessageModel.createText({
    required String id,
    required String chatId,
    required String senderID,
    required String text,
    DateTime? sentTime,
  }) {
    final now = sentTime ?? DateTime.now();
    return ChatMessageModel(
      id: id,
      chatId: chatId,
      senderID: senderID,
      type: MessageType.TEXT,
      text: text,
      sentTime: now,
      seenBy: [senderID],
    );
  }
}
