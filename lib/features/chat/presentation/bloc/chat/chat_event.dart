import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String chatId;
  const LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class UpdateCurrentMessage extends ChatEvent {
  final String message;
  const UpdateCurrentMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendTextMessage extends ChatEvent {
  final String message;
  const SendTextMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendImageMessage extends ChatEvent {}

class DeleteChat extends ChatEvent {}

class GoBack extends ChatEvent {}
