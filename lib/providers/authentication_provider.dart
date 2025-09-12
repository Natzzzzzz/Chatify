import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

// Models
import '../features/chat/data/models/chat_user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NavigationService _navigationService =
      GetIt.instance.get<NavigationService>();
  final DatabaseService _databaseService =
      GetIt.instance.get<DatabaseService>();

  late ChatUserModel _user;
  ChatUserModel get user => _user;

  AuthenticationProvider() {
    if (_auth != null) {
      _auth.authStateChanges().listen(_onAuthStateChanged);
    }
  }

  /// Lắng nghe thay đổi trạng thái đăng nhập
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _databaseService.updateUserLastSeenTime(firebaseUser.uid);

      final snapshot = await _databaseService.getUser(firebaseUser.uid);
      final userData = snapshot.data() as Map<String, dynamic>;

      _user = ChatUserModel.fromJson({
        "uid": firebaseUser.uid,
        "email": userData["email"],
        "name": userData["name"],
        "last_active": userData["last_active"],
        "image": userData["image"],
      });

      notifyListeners();
      _navigationService.removeAndNavigateToRoute('/home');
    } else {
      _user = ChatUserModel(
        uid: '',
        name: '',
        email: '',
        imageURL: '',
        lastActive: DateTime.now(),
      );
      notifyListeners();
      _navigationService.removeAndNavigateToRoute('/login');
    }
  }

  /// Đăng nhập bằng email và password
  Future<void> loginUsingEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.message}");
    } catch (e) {
      debugPrint("Unknown error during login: $e");
    }
  }

  /// Đăng ký người dùng mới
  Future<String?> registerUserUsingEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        debugPrint("Firebase UID: ${user.uid}");
        return user.uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException during register: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Unknown error during register: $e");
      return null;
    }
  }

  /// Đăng xuất
  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }
}
