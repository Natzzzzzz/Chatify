//Packages
import 'package:chatify_app/features/chat/domain/entities/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Model
import '../features/chat/data/models/chat_message_model.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGE_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {
    // Initialize any necessary services or configurations here
  }

  // ================= USER =================

  Future<void> createUser(
    String _uid,
    String _email,
    String _name,
    String _imageURL,
  ) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set(
        {
          "email": _email,
          "image": _imageURL,
          "last_active": DateTime.now().toUtc(),
          "name": _name,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentSnapshot> getUser(String _uid) {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = _db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: "${name}z");
    }
    return _query.get();
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      final docRef = _db.collection(USER_COLLECTION).doc(_uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          "last_active": DateTime.now().toUtc(),
        });
      } else {
        print("User document not found, skipping update.");
      }
    } catch (e) {
      print("Error updating last seen: $e");
    }
  }

  // ================= CHAT =================

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  Future<void> deleteChat(String _chatID) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat =
          await _db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> updateChatData(
    String _chatID,
    Map<String, dynamic> _data,
  ) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).update(_data);
    } catch (e) {
      print(e);
    }
  }

  // ================= MESSAGE =================

  /// Lấy last message (query thô – vẫn dùng ở chỗ cũ nếu bạn muốn)
  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sentAt", descending: true)
        .limit(1)
        .get();
  }

  /// Lấy stream message cho chat (dùng trong Bloc / GetMessages)
  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sentAt", descending: false)
        .snapshots();
  }

  /// Thêm message (đã theo schema mới qua ChatMessageModel.toJson)
  Future<void> addMessageToChat(
    String _chatID,
    ChatMessageModel _message,
  ) async {
    try {
      final messagesRef = _db
          .collection(CHAT_COLLECTION)
          .doc(_chatID)
          .collection(MESSAGE_COLLECTION);

      // tạo doc mới, dùng id của Firestore luôn
      final docRef = await messagesRef.add(_message.toJson());

      // cập nhật lại field id trong document cho khớp domain entity
      await docRef.update({"id": docRef.id});
    } catch (e) {
      print(e);
    }
  }

  /// Helper: gửi text message theo model mới
  Future<void> sendTextMessage(
      {required String chatId,
      required String senderId,
      required String text,
      required}) async {
    try {
      final now = DateTime.now();

      final msg = ChatMessageModel.createText(
        id: "", // sẽ overwrite bằng docRef.id sau
        chatId: chatId,
        senderID: senderId,
        text: text,
        sentTime: now,
      );

      final messagesRef = _db
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .collection(MESSAGE_COLLECTION);

      final docRef = await messagesRef.add(msg.toJson());
      await docRef.update({"id": docRef.id});

      // Optional: update last message cho list chat
      await updateChatData(chatId, {
        "lastMessage": text,
        "lastSentAt": Timestamp.fromDate(now),
      });
    } catch (e) {
      print("sendTextMessage error: $e");
    }
  }

  /// Helper: gửi system message (ví dụ khi tạo group)
  Future<void> sendSystemMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      final now = DateTime.now();

      final msg = ChatMessageModel(
        id: "",
        chatId: chatId,
        senderID: "system",
        type: MessageType.SYSTEM,
        text: text,
        sentTime: now,
        seenBy: const [],
      );

      final messagesRef = _db
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .collection(MESSAGE_COLLECTION);

      final docRef = await messagesRef.add(msg.toJson());
      await docRef.update({"id": docRef.id});
    } catch (e) {
      print("sendSystemMessage error: $e");
    }
  }
}
