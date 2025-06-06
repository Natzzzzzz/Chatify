import 'package:chatify_app/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Models
import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    // _auth.signOut();
    _auth.authStateChanges().listen(
      (_user) {
        if (_user != null) {
          _databaseService.updateUserLastSeenTime(_user.uid);
          _databaseService.getUser(_user.uid).then(
            (_snapshot) {
              Map<String, dynamic> _userData =
                  _snapshot.data()! as Map<String, dynamic>;
              user = ChatUser.fromJSON(
                {
                  "uid": _user.uid,
                  "email": _userData["email"],
                  "name": _userData["name"],
                  "last_active": _userData["last_active"],
                  "image": _userData["image"],
                },
              );
              _navigationService.removeAndNavigateToRoute('/home');
              print('home');
            },
          );
        } else {
          _navigationService.removeAndNavigateToRoute('/login');
        }
      },
    );
  }

  Future<void> loginUsingEmailAndPasswrod(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException {
      print("Error logging user into Firebase");
    } catch (e) {
      print(e);
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        print("Firebase UID: ${user.uid}");
        return user.uid;
      } else {
        print("User is null despite successful credential.");
        return null;
      }
    } catch (e) {
      print("Error during register: $e");
      return null;
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
