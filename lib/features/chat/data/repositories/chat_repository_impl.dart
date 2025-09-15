import 'package:file_picker/file_picker.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) {
    return remoteDataSource.sendMessage(chatId, message);
  }

  @override
  Future<void> deleteChat(String chatId) {
    return remoteDataSource.deleteChat(chatId);
  }

  @override
  Future<String> uploadChatImage(
      String chatId, String userId, PlatformFile file) {
    return remoteDataSource.uploadChatImage(chatId, userId, file);
  }
}
