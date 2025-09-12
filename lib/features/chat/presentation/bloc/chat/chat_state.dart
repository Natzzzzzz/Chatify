import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final List<ChatMessage>? messages;
  final bool isLoading;
  final String? currentMessage;

  const ChatState({
    this.messages,
    this.isLoading = false,
    this.currentMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? currentMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      currentMessage: currentMessage ?? this.currentMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, currentMessage];
}
