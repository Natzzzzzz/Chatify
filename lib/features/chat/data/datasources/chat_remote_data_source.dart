import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessage>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, ChatMessage message);
  Future<void> deleteChat(String chatId);
  Future<String> uploadChatImage(
      String chatId, String userId, PlatformFile file);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRemoteDataSourceImpl(this.firestore, this.storage);

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return firestore
        .collection("Chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("sent_time", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    final model = ChatMessageModel(
      senderID: message.senderID,
      type: message.type,
      content: message.content,
      sentTime: message.sentTime,
    );
    await firestore
        .collection("Chats")
        .doc(chatId)
        .collection("messages")
        .add(model.toJson());
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await firestore.collection("Chats").doc(chatId).delete();
  }

  @override
  Future<String> uploadChatImage(
      String chatId, String userId, PlatformFile file) async {
    final ref = storage.ref().child(
        "chats/$chatId/${DateTime.now().millisecondsSinceEpoch}_${file.name}");

    UploadTask uploadTask;
    if (file.bytes != null) {
      uploadTask = ref.putData(file.bytes!);
    } else {
      uploadTask = ref.putFile(File(file.path!));
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
