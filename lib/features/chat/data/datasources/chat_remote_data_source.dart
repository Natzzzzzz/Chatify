import 'dart:io';

import '/services/cloud_storage_service.dart';
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
    String chatId,
    String userId,
    PlatformFile file, {
    Function(double progress)? onProgress,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final CloudStorageService storageService; // ← Inject service

  ChatRemoteDataSourceImpl(this.firestore, this.storageService);

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
    // Delete Firestore data
    await firestore.collection("Chats").doc(chatId).delete();

    // Delete Storage images
    await storageService.deleteChatImages(chatId);
  }

  @override
  Future<String> uploadChatImage(
    String chatId,
    String userId,
    PlatformFile file, {
    Function(double progress)? onProgress,
  }) async {
    final url = await storageService.saveChatImageToStorage(
      chatId,
      userId,
      file,
      onProgress: onProgress,
    );

    if (url == null) {
      throw Exception('Upload image failed');
    }

    return url;
  }
}
