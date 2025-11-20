import '/services/cloud_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

// Domain
import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/get_messages.dart';
import '../../../domain/repositories/chat_repository.dart';

// Providers & Services
import '../../../../../providers/authentication_provider.dart';
import '../../../../../services/navigation_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final String chatId;
  final AuthenticationProvider auth;
  final ScrollController scrollController;
  final NavigationService navigation;
  final ChatRepository repository;
  final GetMessages getMessages;

  ChatBloc({
    required this.chatId,
    required this.auth,
    required this.scrollController,
    required this.navigation,
    required this.repository,
    required this.getMessages,
  }) : super(const ChatState()) {
    on<LoadMessages>(_onLoadMessages);
    on<UpdateCurrentMessage>(_onUpdateCurrentMessage);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<DeleteChat>(_onDeleteChat);
    on<GoBack>(_onGoBack);
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true));

    await emit.forEach<List<ChatMessage>>(
      getMessages(chatId),
      onData: (messages) {
        // emit state
        final newState = state.copyWith(messages: messages, isLoading: false);

        // scroll sau khi emit
        _scrollToBottom();

        return newState;
      },
      onError: (_, __) => state.copyWith(isLoading: false),
    );
  }

  void _onUpdateCurrentMessage(
      UpdateCurrentMessage event, Emitter<ChatState> emit) {
    emit(state.copyWith(currentMessage: event.message));
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<ChatState> emit) async {
    if (event.message.trim().isEmpty) return;

    final newMessage = ChatMessage(
      senderID: auth.user.uid,
      type: MessageType.TEXT,
      content: event.message,
      sentTime: DateTime.now(),
    );

    await repository.sendMessage(chatId, newMessage);
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // 1. Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Quan trọng cho Web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // 2. Emit uploading state
        emit(state.copyWith(
          isUploading: true,
          uploadProgress: 0.0,
        ));

        // 3. Upload với progress callback
        final cloudStorageService = CloudStorageService();
        final downloadUrl = await cloudStorageService.saveChatImageToStorage(
          chatId,
          auth.user.uid,
          file,
          onProgress: (progress) {
            // Update progress trong state
            emit(state.copyWith(uploadProgress: progress));
          },
        );

        if (downloadUrl == null) {
          throw Exception('Upload failed');
        }

        // 4. Create message
        final newMessage = ChatMessage(
          senderID: auth.user.uid,
          type: MessageType.IMAGE,
          content: downloadUrl,
          sentTime: DateTime.now(),
        );

        // 5. Send message
        await repository.sendMessage(chatId, newMessage);

        // 6. Clear uploading state
        emit(state.copyWith(
          isUploading: false,
          uploadProgress: 0.0,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isUploading: false,
        uploadProgress: 0.0,
      ));
    }
  }

  void _onDeleteChat(DeleteChat event, Emitter<ChatState> emit) async {
    await repository.deleteChat(chatId);
    navigation.goBack();
  }

  void _onGoBack(GoBack event, Emitter<ChatState> emit) {
    navigation.goBack(true);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
