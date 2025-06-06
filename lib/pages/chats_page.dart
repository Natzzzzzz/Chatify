//Packages
import 'package:chatify_app/widgets/custom_list_view_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
import '../providers/authentication_provider.dart';

//Widgets
import '../widgets/top_bar.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.04),
      height: _deviceHeight * 0.95,
      width: _deviceWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TopBar(
            'Chats',
            primaryAction: IconButton(
              onPressed: () {
                _auth.logOut();
              },
              icon: Icon(
                Icons.logout,
                color: Color.fromRGBO(0, 82, 218, 1.0),
              ),
            ),
          ),
          _chatList(),
        ],
      ),
    );
  }

  Widget _chatList() {
    return Expanded(
      child: _chatTile(),
    );
  }

  Widget _chatTile() {
    return CustomListViewTileWithActivity(
        height: _deviceHeight * 0.10,
        title: "Hussain Mustafa",
        subtitle: "Hello",
        imagePath:
            "https://www.cameo.com/cdn-cgi/image/fit=cover,format=auto,width=210,height=278/https://cdn.cameo.com/thumbnails/67b59723c0ee9f79d46798f2-processed.jpg",
        isActive: true,
        isActivity: false,
        onTap: () {});
  }
}
