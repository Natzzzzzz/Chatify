import '/services/cloud_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  /// Stream tin nhắn realtime
  Stream<List<ChatMessage>> getMessages(String chatId);

  /// Gửi 1 message (text / image / file / location...)
  Future<void> sendMessage(ChatMessageModel message);

  /// Xoá cuộc chat + ảnh trong storage
  Future<void> deleteChat(String chatId);

  /// Helper gửi TEXT đơn giản
  Future<void> sendText({
    required String chatId,
    required String senderId,
    required String text,
  });

  /// Upload ảnh chat, có callback progress
  Future<String> uploadChatImage(
    String chatId,
    String userId,
    PlatformFile file, {
    Function(double progress)? onProgress,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudStorageService _storageService;

  ChatRemoteDataSourceImpl(this._firestore, this._storageService);

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return null;
            }

            try {
              return ChatMessageModel.fromJson(doc.id, data);
            } catch (e, s) {
              return null;
            }
          })
          .where((m) => m != null)
          .cast<ChatMessage>()
          .toList();
    });

    // ChatMessageModel extends ChatMessage → trả về List<ChatMessage> OK
  }

  @override
  Future<void> sendMessage(ChatMessageModel message) async {
    final ref = _firestore
        .collection('Chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id); // id đã có trong model

    await ref.set(message.toJson());
  }

  @override
  Future<void> deleteChat(String chatId) async {
    // Xoá document chat
    await _firestore.collection("Chats").doc(chatId).delete();

    // Xoá luôn ảnh trong Storage
    await _storageService.deleteChatImages(chatId);
  }

  @override
  Future<void> sendText({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messagesRef =
        _firestore.collection('Chats').doc(chatId).collection('messages');

    // Tạo doc id mới
    final doc = messagesRef.doc();

    final message = ChatMessageModel.createText(
      id: doc.id,
      chatId: chatId,
      senderID: senderId,
      text: text,
    );

    await doc.set(message.toJson());
  }

  @override
  Future<String> uploadChatImage(
    String chatId,
    String userId,
    PlatformFile file, {
    Function(double progress)? onProgress,
  }) async {
    final url = await _storageService.saveChatImageToStorage(
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
