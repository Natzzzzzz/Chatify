import 'package:file_picker/file_picker.dart';

import '../entities/chat_message.dart';

abstract class ChatRepository {
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
