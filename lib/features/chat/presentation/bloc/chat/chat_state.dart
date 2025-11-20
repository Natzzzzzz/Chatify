import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage>? messages;
  final bool isLoading;
  final String? currentMessage;
  final String? errorMessage;
  final bool isUploading;
  final double uploadProgress;

  const ChatState({
    this.messages,
    this.isLoading = false,
    this.currentMessage,
    this.errorMessage,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? currentMessage,
    String? errorMessage,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentMessage: currentMessage ?? this.currentMessage,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        currentMessage,
        isUploading,
        uploadProgress,
      ];
}
