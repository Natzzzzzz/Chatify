import 'dart:async';

import 'package:chatify_app/features/chat/data/datasources/chat_remote_data_source.dart';
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
  final ChatRemoteDataSource _remote;
  StreamSubscription? _sub;

  final String chatId;
  final AuthenticationProvider auth;
  final ScrollController scrollController;
  final NavigationService navigation;
  final ChatRepository repository;
  final GetMessages getMessages;

  ChatBloc({
    required ChatRemoteDataSource remote,
    required this.chatId,
    required this.auth,
    required this.scrollController,
    required this.navigation,
    required this.repository,
    required this.getMessages,
  })  : _remote = remote,
        super(const ChatState()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatTextMessageSent>(_onChatTextMessageSent);
    // on<UpdateCurrentMessage>(_onUpdateCurrentMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<DeleteChat>(_onDeleteChat);
    on<GoBack>(_onGoBack);
  }

  Future<void> _onChatStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    await _sub?.cancel();

    _sub = _remote.getMessages(event.chatId).listen(
      (messages) {
        emit(state.copyWith(
          isLoading: false,
          messages: messages,
          errorMessage: null,
        ));
        _scrollToBottom();
      },
      onError: (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      },
    );
  }

  // void _onUpdateCurrentMessage(
  //   UpdateCurrentMessage event,
  //   Emitter<ChatState> emit,
  // ) {
  //   // nếu bạn vẫn giữ currentMessage trong ChatState
  //   emit(state.copyWith(currentMessage: event.message));
  // }

  Future<void> _onChatTextMessageSent(
    ChatTextMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.text.trim().isEmpty) return;

    try {
      await _remote.sendText(
        chatId: event.chatId,
        senderId: event.senderId,
        text: event.text,
      );
      // Firestore stream sẽ tự bắn messages mới về
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gửi tin nhắn thất bại'));
    }
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // 1. Pick file ảnh
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // quan trọng cho Web
      );

      if (result == null || result.files.isEmpty) {
        return; // user cancel
      }

      final file = result.files.first;

      // 2. Bật trạng thái uploading
      emit(state.copyWith(
        isUploading: true,
        uploadProgress: 0.0,
        errorMessage: null,
      ));

      // 3. Upload qua repository, nhận URL + progress
      final downloadUrl = await repository.uploadChatImage(
        chatId,
        auth.user.uid,
        file,
        onProgress: (progress) {
          emit(state.copyWith(uploadProgress: progress));
        },
      );

      // 4. Tạo ChatMessage IMAGE (Bloc chỉ tạo entity, không Firebase)
      final messageId =
          DateTime.now().microsecondsSinceEpoch.toString(); // id đơn giản

      final newMessage = ChatMessage(
        id: messageId,
        chatId: chatId,
        senderID: auth.user.uid,
        type: MessageType.IMAGE,
        text: null,
        fileUrl: downloadUrl,
        fileName: file.name,
        fileSize: file.size,
        sentTime: DateTime.now(),
        seenBy: [auth.user.uid],
      );

      // 5. Gửi message lên qua repository
      await repository.sendMessage(chatId, newMessage);

      // 6. Clear uploading state
      emit(state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
      ));

      _scrollToBottom();
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        isUploading: false,
        uploadProgress: 0.0,
      ));
    }
  }

  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatState> emit,
  ) async {
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

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
