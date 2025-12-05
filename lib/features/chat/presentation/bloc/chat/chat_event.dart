import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// bắt đầu lắng nghe 1 cuộc chat
class ChatStarted extends ChatEvent {
  final String chatId;

  const ChatStarted(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

// khi user gửi tin nhắn text
class ChatTextMessageSent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String text;

  const ChatTextMessageSent({
    required this.chatId,
    required this.senderId,
    required this.text,
  });

  @override
  List<Object?> get props => [chatId, senderId, text];
}

class UpdateCurrentMessage extends ChatEvent {
  final String message;
  const UpdateCurrentMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendImageMessage extends ChatEvent {}

class DeleteChat extends ChatEvent {}

class GoBack extends ChatEvent {}
