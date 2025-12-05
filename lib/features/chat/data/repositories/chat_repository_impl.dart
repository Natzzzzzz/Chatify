import 'package:file_picker/file_picker.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) {
    // Nếu đã là ChatMessageModel thì dùng luôn
    final ChatMessageModel model = message is ChatMessageModel
        ? message
        : ChatMessageModel(
            id: message.id,
            chatId: message.chatId,
            senderID: message.senderID,
            type: message.type,
            text: message.text,
            fileUrl: message.fileUrl,
            fileName: message.fileName,
            fileSize: message.fileSize,
            location: message.location,
            sentTime: message.sentTime,
            seenBy: message.seenBy,
          );

    return remoteDataSource.sendMessage(model);
  }

  @override
  Future<void> deleteChat(String chatId) {
    return remoteDataSource.deleteChat(chatId);
  }

  @override
  Future<String> uploadChatImage(
    String chatId,
    String userId,
    PlatformFile file, {
    Function(double progress)? onProgress,
  }) {
    return remoteDataSource.uploadChatImage(
      chatId,
      userId,
      file,
      onProgress: onProgress,
    );
  }
}
