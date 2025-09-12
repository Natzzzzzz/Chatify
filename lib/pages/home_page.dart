//Packages
import 'package:chatify_app/providers/authentication_provider.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:chatify_app/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

//Pages
import '../features/chat/presentation/pages/list_chat_page.dart';
import '../pages/users_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigationService;

  int _currentPage = 0;
  final List<Widget> _pages = [
    ChatsPage(),
    UsersPage(),
  ];
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigationService = GetIt.instance.get<NavigationService>();

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (_index) {
            setState(() {
              _currentPage = _index;
            });
          },
          items: [
            BottomNavigationBarItem(
              label: "Chats",
              icon: Icon(Icons.chat_bubble_sharp),
            ),
            BottomNavigationBarItem(
              label: "Users",
              icon: Icon(Icons.supervised_user_circle_sharp),
            ),
          ]),
    );
  }
}
