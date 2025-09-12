import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat.dart';

class ChatsState extends Equatable {
  final List<Chat>? chats;
  final bool isLoading;
  final String? errorMessage;

  const ChatsState({
    this.chats,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatsState copyWith({
    List<Chat>? chats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [chats, isLoading, errorMessage];
}
