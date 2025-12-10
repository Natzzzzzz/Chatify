//Packages
import 'package:chatify_app/widgets/system_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/rendering.dart';
//Widgets
import '../widgets/rounded_image.dart';
import '../widgets/message_bubbles.dart';

//Domain
import '../features/chat/domain/entities/chat_user.dart';
import '../features/chat/domain/entities/chat_message.dart';

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  CustomListViewTile({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: isSelected ? Icon(Icons.check, color: Colors.white) : null,
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        imagePath: imagePath,
        size: height / 2,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  CustomListViewTileWithActivity({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      contentPadding: EdgeInsets.zero, //REMOVE DEFAULT CONTENT PADDING
      minVerticalPadding: height * 0.01,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        size: height / 1.8,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  color: Colors.white54,
                  size: height * 0.10,
                ),
              ],
            )
          : Text(
              subtitle,
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser? sender;

  CustomChatListViewTile({
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    this.sender,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.SYSTEM) {
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: SystemMessageBubble(message: message),
      );
    }

    // ⭐ Các loại message còn lại: có avatar (nếu không phải của mình)
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (!isOwnMessage && sender != null)
              ? RoundedImageNetwork(
                  key: UniqueKey(),
                  imagePath: sender!.imageURL,
                  size: width * 0.1,
                )
              : const SizedBox.shrink(),
          SizedBox(width: width * 0.045),
          Flexible(
            child: _buildMessageBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    switch (message.type) {
      case MessageType.IMAGE:
        return ImageMessageBubble(
          isOwnMessage: isOwnMessage,
          message: message,
          height: deviceHeight * 0.3,
          width: width * 0.55,
        );
      // case MessageType.FILE:
      //   return FileMessageBubble(
      //     isOwnMessage: isOwnMessage,
      //     message: message,
      //     width: width * 0.55,
      //   );

      // // sau này enum có LOCATION
      // case MessageType.LOCATION:
      //   return LocationMessageBubble(
      //     isOwnMessage: isOwnMessage,
      //     message: message,
      //     width: width * 0.55,
      //   );
      case MessageType.TEXT:
      default:
        return TextMessageBubble(
          isOwnMessage: isOwnMessage,
          message: message,
          height: deviceHeight * 0.06,
          width: width * 0.7,
        );
    }
  }
}
