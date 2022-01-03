import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unico/Services/database.dart';
import 'package:unico/models/message_modal.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/shared/loading.dart';
class ChatScreen extends StatefulWidget {
  final UnicoUser toUser;
  final UnicoUser currentUser;
  final String chatRoomId;
  const ChatScreen({Key? key, required this.toUser, required this.currentUser, required this.chatRoomId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseService database = DatabaseService();
  bool loading = false;
  TextEditingController messageController = TextEditingController();
  Stream<List<Message>> ? chatMessagesStream;

  @override
  void initState() {
    super.initState();
    setState(()=> loading = true);
    database.resetUnread(chatRoomId: widget.chatRoomId, myId:  widget.currentUser.uid);
    chatMessagesStream = database.getConversationMessages(currentUser: widget.currentUser,toUser: widget.toUser);
    setState(()=> loading = false);
  }

  Future<void> _sendMessage({required String text,}) async{
    if(messageController.text.isNotEmpty){
    await database.addMessage(currentUserId: widget.currentUser.uid,userId: widget.toUser.uid, message:Message(text: text, sender: widget.currentUser, time: DateTime.now()));
    messageController.clear();
    FocusScope.of(context).unfocus();
    }
  }

  Widget _buildMessageComposer() => Container(
    margin: EdgeInsets.only(bottom: context.mediaQueryPadding.bottom),
    padding: const EdgeInsets.fromLTRB(10,10,20,10),
    width: Get.width,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.photo),
          iconSize: 25.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {},
        ),
        Expanded(
          child: TextField(
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: () async => await _sendMessage(text: messageController.text),),
                hintText: 'Send a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                )
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMessage({required Message message, required bool isMe}) =>Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: isMe? const [Color(0xff007EF4), Color(0xff2A75BC)]: const [Colors.black26, Colors.black54]),
      borderRadius: const BorderRadius.all(Radius.circular(12.0),),
    ),
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(message.messageTime,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54
        ),),
        const SizedBox(width: 8,),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:  MediaQuery.of(context).size.width * 0.68,
          ),
          child: Text(message.text,
            style: const TextStyle(color: Colors.white),),
        ),
      ],
    ),
  );
  Widget _buildMessages() => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
      color: Colors.blueGrey,
      child: StreamBuilder(
        stream: chatMessagesStream!,
        builder: (context,AsyncSnapshot<List<Message>> snapshot){
          if(snapshot.hasData && snapshot.data!.isNotEmpty){
            DateTime lastDate = snapshot.data!.first.time;
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Message message = snapshot.data![index];
                bool isMe = message.isMe(myId: widget.currentUser.uid);
                if(!message.isInDate(date: lastDate) || index == 0){
                  lastDate = message.time;
                  return  Column(
                    crossAxisAlignment: isMe? CrossAxisAlignment.start: CrossAxisAlignment.end,
                    children: [
                      Center(child: Text(message.messageDate)),
                      _buildMessage(message: message , isMe: isMe),
                    ],
                  );
                }
                else{
                  return Column(
                    crossAxisAlignment: isMe? CrossAxisAlignment.start: CrossAxisAlignment.end,
                    children: [
                      _buildMessage(message: message , isMe: isMe),
                    ],
                  );
                }
              },
            );
          }
          else{
            return Container();
          }
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: InkWell(
          onTap: ()=> Navigator.pop(context),
          borderRadius: BorderRadius.circular(100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(width: 5,),
              const Icon(Icons.arrow_back),
              const SizedBox(width: 5,),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                backgroundImage: widget.currentUser.userData["profileImageUrl"] != ""?
              NetworkImage(widget.currentUser.userData["profileImageUrl"]):
              const AssetImage("assets/images/default_profile_pic.png") as ImageProvider,
              )
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.toUser.userData["firstName"]+ " " + widget.toUser.userData["lastName"],
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600
              ),
            ),
            const Text(
              "active",
              style: TextStyle(
                fontSize: 14.0,
              ),
            )
          ],
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            _buildMessages(),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}