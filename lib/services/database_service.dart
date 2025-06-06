import 'package:cloud_firestore/cloud_firestore.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGE_COLLECTION = "Messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {
    // Initialize any necessary services or configurations here
  }
  Future<void> createUser(
      String _uid, String _email, String _name, String _imageURL) async {
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
}
