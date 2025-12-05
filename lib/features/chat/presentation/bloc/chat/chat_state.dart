import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool isUploading;
  final double uploadProgress;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        errorMessage,
        isUploading,
        uploadProgress,
      ];
}
