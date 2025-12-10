//Packages
import 'package:chatify_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chatify_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatify_app/features/chat/domain/usecases/get_messages.dart';
import 'package:chatify_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chatify_app/features/chat/presentation/bloc/chat/chat_event.dart';
import 'package:chatify_app/services/cloud_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Widgets
import '../../../../widgets/top_bar.dart';
import '../../../../widgets/custom_list_view_tiles.dart';

//Services
import '../../../../services/navigation_service.dart';

//Auth provider (Auth vẫn dùng Provider)
import '../../../../providers/authentication_provider.dart';

// Domain
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/extensions/chat_extension.dart';
import '../../domain/extensions/chat_user_extension.dart';

// Bloc
import '../bloc/list_chat/list_chat_bloc.dart';
import '../bloc/list_chat/list_chat_event.dart';
import '../bloc/list_chat/list_chat_state.dart';

// Data & Repository
import '../../data/datasources/list_chat_remote_data_source.dart';
import '../../data/repositories/list_chat_repository_impl.dart';
import '../../domain/usecases/get_list_chat.dart';

// Pages
import 'chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = context.read<AuthenticationProvider>();
    _navigation = GetIt.instance.get<NavigationService>();

    // Inject repository + usecase
    final listChatRepository = ListChatRepositoryImpl(
        ListChatRemoteDataSourceImpl(FirebaseFirestore.instance));
    final getChats = GetChats(listChatRepository);

    return BlocProvider(
      create: (_) => ChatsBloc(
        getChats: getChats,
      )..add(LoadChats(_auth.user.uid)),
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * 0.03,
            vertical: _deviceHeight * 0.02,
          ),
          height: _deviceHeight * 0.98,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color.fromRGBO(0, 82, 218, 1.0),
                  ),
                  onPressed: () {
                    _auth.logOut();
                  },
                ),
              ),
              _chatsList(state),
            ],
          ),
        );
      },
    );
  }

  Widget _chatsList(ChatsState state) {
    // Ưu tiên error > !loading && empty > loading
    if (state.errorMessage != null) {
      return Expanded(child: Center(child: Text(state.errorMessage!)));
    }
    if (!state.isLoading && (state.chats == null || state.chats!.isEmpty)) {
      return const Expanded(
          child: Center(
              child: Text(
        "No Chats Found.",
        style: TextStyle(color: Colors.white),
      )));
    }
    if (state.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: state.chats!.length,
        itemBuilder: (BuildContext context, int index) {
          return _chatTile(state.chats![index]);
        },
      ),
    );
  }

  Widget _chatTile(Chat chat) {
    final List<ChatUser> recipients = chat.recipients;
    final bool isActive = recipients.any((u) => u.wasRecentlyActive());
    String subtitleText = "";

    if (chat.messages.isNotEmpty) {
      switch (chat.messages.first.type) {
        case MessageType.IMAGE:
          subtitleText = "Media Attachment";

        case MessageType.TEXT:
        default:
          subtitleText = chat.messages.first.text!;
      }
    }

    return Builder(
      builder: (builderContext) {
        return CustomListViewTileWithActivity(
          height: _deviceHeight * 0.10,
          title: chat.title,
          subtitle: subtitleText,
          imagePath: chat.imageURL,
          isActive: isActive,
          isActivity: chat.activity,
          onTap: () async {
            // builderContext có access đến ChatsBloc
            final chatsBloc = builderContext.read<ChatsBloc>();

            final needReload = await _navigation.navigateToPage(
              BlocProvider(
                create: (_) => ChatBloc(
                  remote: ChatRemoteDataSourceImpl(
                    FirebaseFirestore.instance,
                    CloudStorageService(),
                  ),
                  chatId: chat.uid,
                  auth: _auth,
                  scrollController: ScrollController(),
                  navigation: NavigationService(),
                  repository: ChatRepositoryImpl(
                    ChatRemoteDataSourceImpl(
                      FirebaseFirestore.instance,
                      CloudStorageService(),
                    ),
                  ),
                  getMessages: GetMessages(
                    ChatRepositoryImpl(
                      ChatRemoteDataSourceImpl(
                        FirebaseFirestore.instance,
                        CloudStorageService(),
                      ),
                    ),
                  ),
                )..add(ChatStarted(chat.uid)),
                child: ChatPage(chat: chat),
              ),
            );

            if (needReload == true && mounted) {
              chatsBloc.add(LoadChats(_auth.user.uid));
            }
          },
        );
      },
    );
  }
}
