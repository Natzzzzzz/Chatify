//Packages
import 'package:chatify_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chatify_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatify_app/features/chat/domain/usecases/get_messages.dart';
import 'package:chatify_app/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:chatify_app/features/chat/presentation/bloc/chat/chat_event.dart';
import 'package:chatify_app/services/cloud_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../features/chat/data/models/chat_model.dart';
import '../features/chat/data/models/chat_user_model.dart';

//Domain
import '../features/chat/domain/entities/chat_user.dart';

//Pages
import '../features/chat/presentation/pages/chat_page.dart';

class UsersPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  late NavigationService _nag;

  List<ChatUserModel>? users;
  late List<ChatUserModel> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _db = GetIt.instance.get<DatabaseService>();
    _nag = GetIt.instance.get<NavigationService>();
    getUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      _db.getUsers(name: name).then(
        (_snapshot) {
          users = _snapshot.docs
              .map(
                (_doc) {
                  Map<String, dynamic> _data =
                      _doc.data() as Map<String, dynamic>;
                  _data["uid"] = _doc.id;
                  return ChatUserModel.fromJson(_data);
                },
              )
              .where((user) => user.uid != _auth.user.uid)
              .toList();
          notifyListeners();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void updateSelectedUsers(ChatUser user) {
    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      //Create Chat
      List<String> _membersIDs =
          _selectedUsers.map((_user) => _user.uid).toList();
      _membersIDs.add(_auth.user.uid);
      final bool isGroup = _selectedUsers.length > 1;

      // Nếu là group, đặt groupName mặc định
      final String? groupName =
          isGroup ? _selectedUsers.map((u) => u.name).join(", ") : null;

      // Avatar group có thể để null hoặc tạo random mặc định
      final String? groupAvatar = null;

      DocumentReference? _doc = await _db.createChat({
        "isGroup": isGroup,
        "groupName": groupName,
        "groupAvatar": groupAvatar,
        "isActivity": false,
        "members": _membersIDs,
        "lastMessage": null,
        "lastSentAt": null,
      });
      if (_doc != null) {
        await _db.sendTextMessage(
          chatId: _doc.id,
          senderId: _auth.user.uid,
          text: isGroup ? "Group \"$groupName\" created." : "Say hi",
        );
      }

      //Navigate to Chat Page
      List<ChatUserModel> _members = [];
      for (var _uid in _membersIDs) {
        DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
        Map<String, dynamic> _userData =
            _userSnapshot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapshot.id;
        _members.add(ChatUserModel.fromJson(_userData));
      }

      final ChatModel chat = ChatModel(
        uid: _doc!.id,
        currentUserUid: _auth.user.uid,
        members: _members,
        messages: [],
        activity: false,
        group: isGroup,
      );

      _selectedUsers = [];
      notifyListeners();

      // ⭐ Navigate với BlocProvider
      _nag.navigateToRoute(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ChatBloc(
              remote: ChatRemoteDataSourceImpl(
                FirebaseFirestore.instance,
                CloudStorageService(),
              ),
              chatId: chat.uid,
              auth: _auth,
              scrollController: ScrollController(),
              navigation: NavigationService(),
              repository: ChatRepositoryImpl(ChatRemoteDataSourceImpl(
                  FirebaseFirestore.instance, CloudStorageService())),
              getMessages: GetMessages(
                ChatRepositoryImpl(
                  ChatRemoteDataSourceImpl(
                    FirebaseFirestore.instance,
                    CloudStorageService(),
                  ),
                ),
              ),
            )..add(ChatStarted(chat.uid)), // ⭐ Khởi động chat ngay
            child: ChatPage(chat: chat),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
