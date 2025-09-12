import '../entities/chat.dart';
import '../entities/chat_user.dart';

extension ChatExtension on Chat {
  /// Trả về danh sách recipients (ngoại trừ currentUser)
  List<ChatUser> get recipients {
    return members.where((u) => u.uid != currentUserUid).toList();
  }

  /// Lấy tiêu đề cho chat (tên người nhận hoặc nhóm)
  String get title {
    if (group) {
      return recipients.map((u) => u.name).join(", ");
    } else {
      return recipients.isNotEmpty ? recipients.first.name : "Unknown";
    }
  }

  /// Lấy ảnh đại diện (cá nhân hoặc nhóm)
  String get imageURL {
    if (group) {
      return "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
    } else {
      return recipients.isNotEmpty ? recipients.first.imageURL : "";
    }
  }
}
