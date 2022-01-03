import 'package:flutter/material.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/chat/chat_rooms.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({Key? key, required this.currentUser}) : super(key: key);
  final UnicoUser currentUser;

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back),onPressed: (){Navigator.pop(context);},iconSize: 30,color: Colors.white,),
        title: const Text("Chats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          ChatRooms(currentUser: widget.currentUser),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        splashColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 8,
        mini: true,
        child: const Icon(Icons.search),
        onPressed: () {},

      ),
    );
  }
}
