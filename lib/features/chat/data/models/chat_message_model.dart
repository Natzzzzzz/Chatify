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

  /// Tạo từ DocumentSnapshot (khuyến khích dùng cách này trong stream)
  factory ChatMessageModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatMessageModel.fromJson(doc.id, data);
  }

  /// Tạo từ Map + id (nếu bạn đã có id riêng)
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

    // hỗ trợ cả key cũ (sent_time) lẫn key mới (sentAt)
    final sentField = json["sentAt"] ?? json["sent_time"];
    final sentTimestamp = sentField as Timestamp;

    return ChatMessageModel(
      id: id,
      chatId: json["chatId"] ?? json["chat_id"] ?? "",
      senderID: json["senderId"] ?? json["sender_id"] ?? "",
      type: messageType,

      // text: ưu tiên field mới 'text', fallback về 'content' (data cũ)
      text: json["text"] ?? json["content"],

      // file / image
      fileUrl: json["fileUrl"],
      fileName: json["fileName"],
      fileSize: json["fileSize"],

      // location
      location: json["location"] as GeoPoint?,

      sentTime: sentTimestamp.toDate(),

      // seenBy luôn là List<String>, default []
      seenBy: (json["seenBy"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    // enum -> string
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
      "chatId": chatId,
      "senderId": senderID,
      "type": messageType,

      // text
      "text": text,

      // file / image
      "fileUrl": fileUrl,
      "fileName": fileName,
      "fileSize": fileSize,

      // location
      "location": location,

      // thời gian gửi (schema mới)
      "sentAt": Timestamp.fromDate(sentTime),

      // seen
      "seenBy": seenBy,
    };
  }

  /// Helper tạo message text đơn giản (Phase 1)
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
