import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_user.dart';

class ChatUserModel extends ChatUser {
  ChatUserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.imageURL,
    required super.lastActive,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      uid: json["uid"],
      name: json["name"],
      email: json["email"],
      imageURL: json["image"],
      lastActive: (json["last_active"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "image": imageURL,
      "last_active": lastActive,
    };
  }
}
