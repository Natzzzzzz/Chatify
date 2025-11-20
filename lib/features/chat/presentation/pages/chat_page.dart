//Packages
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Widgets
import '../../../../widgets/top_bar.dart';
import '../../../../widgets/custom_list_view_tiles.dart';
import '../../../../widgets/custom_input_fields.dart';

//Services
import '../../../../services/navigation_service.dart';
import '../../../../services/cloud_storage_service.dart';

// Domain
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';

// Providers
import '../../../../providers/authentication_provider.dart';

// Bloc
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';

// Data & Repository
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/get_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  const ChatPage({required this.chat, Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messageListViewController;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messageListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = context.read<AuthenticationProvider>();

    // Khởi tạo Repository và Usecase
    final cloudStorageService = CloudStorageService();
    final chatRepository = ChatRepositoryImpl(
      ChatRemoteDataSourceImpl(FirebaseFirestore.instance, cloudStorageService),
    );
    final getMessages = GetMessages(chatRepository);

    return BlocProvider(
      create: (_) => ChatBloc(
        chatId: widget.chat.uid,
        auth: _auth,
        scrollController: _messageListViewController,
        navigation: NavigationService(),
        repository: chatRepository,
        getMessages: getMessages,
      )..add(LoadMessages(widget.chat.uid)),
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceHeight * 0.001,
              vertical: _deviceWidth * 0.02,
            ),
            height: _deviceHeight,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(
                  widget.chat.recipients.isNotEmpty
                      ? widget.chat.recipients.first.name
                      : "Chat",
                  fontSize: 15,
                  primaryAction: IconButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(DeleteChat());
                    },
                    icon: const Icon(Icons.delete),
                    color: const Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  secondaryAction: IconButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(GoBack());
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: const Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                ),
                Expanded(child: _messagesListView(state)),
                _uploadProgressIndicator(state),
                _sendMessageForm(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _uploadProgressIndicator(ChatState state) {
    // Chỉ hiển thị khi đang upload
    if (!state.isUploading) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.05,
        vertical: _deviceHeight * 0.015,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color.fromRGBO(0, 82, 218, 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 82, 218, 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud_upload,
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Progress info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đang upload ảnh...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: state.uploadProgress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(0, 82, 218, 1.0),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Percentage
              Text(
                '${(state.uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messagesListView(ChatState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.messages == null || state.messages!.isEmpty) {
      return const Align(
        alignment: Alignment.center,
        child: Text(
          "Be the first to say Hi!",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      controller: _messageListViewController,
      itemCount: state.messages!.length,
      itemBuilder: (BuildContext context, int index) {
        final ChatMessage message = state.messages![index];
        final bool isOwnMessage = message.senderID == _auth.user.uid;

        return CustomChatListViewTile(
          width: _deviceWidth * 0.8,
          deviceHeight: _deviceHeight,
          isOwnMessage: isOwnMessage,
          message: message,
          sender:
              widget.chat.members.firstWhere((m) => m.uid == message.senderID),
        );
      },
    );
  }

  Widget _sendMessageForm(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.02,
      ),
      child: Form(
        key: _messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(context),
            _sendMessageButton(context),
            _imageMessageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField(BuildContext context) {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
        onSaved: (_value) {
          final message = _value?.trim();
          if (message != null && message.isNotEmpty) {
            context.read<ChatBloc>().add(UpdateCurrentMessage(message));
            context.read<ChatBloc>().add(SendTextMessage(message));
          }
        },
        regEx: r"^(?!\s*$).+",
        hintText: "Type a message",
        obscureText: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context) {
    final double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: IconButton(
        onPressed: () {
          if (_messageFormState.currentState!.validate()) {
            _messageFormState.currentState!.save();
            _messageFormState.currentState!.reset();
          }
        },
        icon: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }

  Widget _imageMessageButton(BuildContext context) {
    final double size = _deviceHeight * 0.04;
    return SizedBox(
      height: size,
      width: size,
      child: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(0, 82, 218, 1.0),
        onPressed: () {
          // Dispatch event tới ChatBloc
          context.read<ChatBloc>().add(SendImageMessage());
        },
        child: const Icon(Icons.camera_enhance, color: Colors.white),
      ),
    );
  }
}
