import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  TEXT,
  IMAGE,
  FILE,
  LOCATION,
  SYSTEM,
  UNKNOWN,
}

class ChatMessage {
  final String id;
  final String chatId; // id đoạn chat / group
  final String senderID;
  final MessageType type;

  // text
  final String? text;

  // file / image
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  // location
  final GeoPoint? location;

  // thời gian gửi
  final DateTime sentTime;

  // seen
  final List<String> seenBy;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderID,
    required this.type,
    this.text,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.location,
    required this.sentTime,
    this.seenBy = const [],
  });
}
