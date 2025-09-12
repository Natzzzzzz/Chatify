import 'package:equatable/equatable.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatsEvent {
  final String userId;
  const LoadChats(this.userId);
  @override
  List<Object?> get props => [userId];
}
