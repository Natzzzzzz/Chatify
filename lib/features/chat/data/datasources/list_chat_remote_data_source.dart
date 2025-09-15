import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
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
        .asyncExpand((snapshot) {
      final chatStreams = snapshot.docs.map((doc) {
        final data = doc.data();

        // Stream tin nhắn cuối cùng (luôn update khi có thay đổi)
        final messageStream = firestore
            .collection('Chats')
            .doc(doc.id)
            .collection('messages')
            .orderBy('sent_time', descending: true)
            .limit(1)
            .snapshots()
            .map((msgSnap) {
          if (msgSnap.docs.isNotEmpty) {
            return [
              ChatMessageModel.fromJson(msgSnap.docs.first.data()),
            ];
          }
          return <ChatMessage>[];
        });

        // Kết hợp với info user
        return messageStream.asyncMap((messages) async {
          final members = await Future.wait(
            (data['members'] as List).map((uid) async {
              final userSnap =
                  await firestore.collection('Users').doc(uid).get();
              final userData = userSnap.data()!..['uid'] = userSnap.id;
              return ChatUserModel.fromJson(userData);
            }),
          );

          return ChatModel.fromFirestore(
            id: doc.id,
            data: data,
            members: members,
            messages: messages,
            currentUserUid: userId,
          );
        });
      });

      return Rx.combineLatestList(chatStreams);
    });
  }
}
