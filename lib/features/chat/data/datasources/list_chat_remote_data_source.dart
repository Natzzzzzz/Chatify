import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_user.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_model.dart';
import '../models/chat_user_model.dart';
import '../models/chat_message_model.dart';

abstract class ListChatRemoteDataSource {
  Stream<List<Chat>> getChats(String userId);
}

class ListChatRemoteDataSourceImpl implements ListChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ListChatRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<Chat>> getChats(String userId) {
    return firestore
        .collection('Chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final chats = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();

        // Lấy thành viên
        List<ChatUser> members = [];
        for (var uid in data['members']) {
          final userSnap = await firestore.collection('Users').doc(uid).get();
          final userData = userSnap.data()!..['uid'] = userSnap.id;
          members.add(ChatUserModel.fromJson(userData));
        }

        // Lấy tin nhắn cuối
        List<ChatMessage> messages = [];
        final lastMessageSnap = await firestore
            .collection('Chats')
            .doc(doc.id)
            .collection('messages')
            .orderBy('sent_time', descending: true)
            .limit(1)
            .get();

        if (lastMessageSnap.docs.isNotEmpty) {
          messages.add(
            ChatMessageModel.fromJson(lastMessageSnap.docs.first.data()),
          );
        }

        return ChatModel.fromFirestore(
          id: doc.id,
          data: data,
          members: members,
          messages: messages,
          currentUserUid: userId,
        );
      }));

      return chats;
    });
  }
}
