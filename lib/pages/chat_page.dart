//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/custom_input_fields.dart';

//Services
import '../services/navigation_service.dart';

//Models
import '../models/chat.dart';
import '../models/chat_message.dart';

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  ChatPage({required this.chat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;

  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messageListViewController;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messageListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);

    return MultiProvider(providers: [
      ChangeNotifierProvider<ChatPageProvider>(
          create: (_) => ChatPageProvider(
              this.widget.chat.uid, _auth, _messageListViewController))
    ], child: _buildUI());
  }

  Widget _buildUI() {
    return Builder(builder: (context) {
      _pageProvider = context.watch<ChatPageProvider>();
      return Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceHeight * 0.001, vertical: _deviceWidth * 0.02),
          height: _deviceHeight,
          width: _deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopBar(
                this.widget.chat.title(),
                fontSize: 15,
                primaryAction: IconButton(
                  onPressed: () {
                    _pageProvider.deleteChat();
                  },
                  icon: Icon(Icons.delete),
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
                secondaryAction: IconButton(
                  onPressed: () {
                    _pageProvider.goBack();
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Color.fromRGBO(0, 82, 218, 1.0),
                ),
              ),
              Expanded(child: _messagesListView()),
              _sendMessageForm(),
            ],
          ),
        ),
      );
    });
  }

  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.length != 0) {
        return Container(
          // height: _deviceHeight * 0.74,
          child: ListView.builder(
              controller: _messageListViewController,
              itemCount: _pageProvider.messages!.length,
              itemBuilder: (BuildContext _context, int _index) {
                ChatMessage _message = _pageProvider.messages![_index];
                bool _isOwnMessage = _message.senderID == _auth.user.uid;
                return Container(
                  child: CustomChatListViewTile(
                      width: _deviceWidth * 0.8,
                      deviceHeight: _deviceHeight,
                      isOwnMessage: _isOwnMessage,
                      message: _message,
                      sender: this
                          .widget
                          .chat
                          .members
                          .where((_m) => _m.uid == _message.senderID)
                          .first),
                );
              }),
        );
      } else {
        return Align(
          alignment: Alignment.center,
          child: Text(
            "Be the first to say Hi!",
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }

  Widget _sendMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: Color.fromRGBO(30, 29, 37, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.02,
      ),
      child: Form(
          key: _messageFormState,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _messageTextField(),
              _sendMessageButton(),
              _imageMessageButton(),
            ],
          )),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
          onSaved: (_value) {
            _pageProvider.message = _value;
          },
          regEx: r"^(?!\s*$).+",
          hintText: "Type a message",
          obscureText: false),
    );
  }

  Widget _sendMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: IconButton(
          onPressed: () {
            if (_messageFormState.currentState!.validate()) {
              _messageFormState.currentState!.save();
              _pageProvider.sendTextMessage();
              _messageFormState.currentState!.reset();
            }
          },
          icon: Icon(
            Icons.send,
            color: Colors.white,
          )),
    );
  }

  Widget _imageMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        backgroundColor: Color.fromRGBO(0, 82, 218, 1.0),
        onPressed: () {
          _pageProvider.sendImageMessage();
        },
        child: Icon(
          Icons.camera_enhance,
          color: Colors.white,
        ),
      ),
    );
  }
}
