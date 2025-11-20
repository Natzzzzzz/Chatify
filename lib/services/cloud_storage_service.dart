import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

const String USER_COLLECTION = "Users";

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload ảnh profile của user
  Future<String?> saveUserImageToStorage(
    String _uid,
    PlatformFile _file, {
    Function(double progress)? onProgress,
  }) async {
    try {
      Reference _ref =
          _storage.ref().child('images/users/$_uid/profile.${_file.extension}');

      UploadTask _task;
      if (_file.path != null) {
        // Mobile: dùng file path
        _task = _ref.putFile(File(_file.path!));
      } else {
        throw Exception('File không hợp lệ');
      }

      // Listen to progress
      if (onProgress != null) {
        _task.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion and get URL
      final snapshot = await _task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading user image: $e');
      return null;
    }
  }

  /// Upload ảnh trong chat với progress tracking
  Future<String?> saveChatImageToStorage(
    String _chatID,
    String _userID,
    PlatformFile _file, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final timestamp = Timestamp.now().millisecondsSinceEpoch;
      Reference _ref = _storage.ref().child(
          'images/chats/$_chatID/${_userID}_$timestamp.${_file.extension}');

      UploadTask _task;
      if (_file.path != null) {
        _task = _ref.putFile(
          File(_file.path!),
          SettableMetadata(
            contentType: 'image/${_file.extension}',
            customMetadata: {
              'uploadedBy': _userID,
              'chatId': _chatID,
              'timestamp': timestamp.toString(),
            },
          ),
        );
      } else {
        throw Exception('File không hợp lệ');
      }

      // ← THÊM PROGRESS TRACKING
      if (onProgress != null) {
        _task.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion and get URL
      final snapshot = await _task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading chat image: $e');
      return null;
    }
  }

  /// Delete ảnh từ Storage (useful khi xóa chat/user)
  Future<bool> deleteImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete tất cả ảnh trong chat
  Future<bool> deleteChatImages(String chatId) async {
    try {
      final ref = _storage.ref().child('images/chats/$chatId');
      final listResult = await ref.listAll();

      // Delete all files
      for (var item in listResult.items) {
        await item.delete();
      }

      return true;
    } catch (e) {
      print('Error deleting chat images: $e');
      return false;
    }
  }
}
