import 'package:flutter/material.dart';
import 'package:unico/models/chat_room_modal.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/chat/chat_screen.dart';
import 'package:unico/Services/database.dart';
import 'package:unico/shared/loading.dart';

class ChatRooms extends StatefulWidget {
  final UnicoUser currentUser;
  const ChatRooms({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ChatRoomsState createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  final DatabaseService database = DatabaseService();
  Stream<List<ChatRoom>>? chatRoomsStream;
  @override
  void initState() {
    chatRoomsStream = database.getChatRooms(user: widget.currentUser);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
        color: Colors.blueGrey,
        child: StreamBuilder(
            stream: chatRoomsStream!,
            builder: (context, AsyncSnapshot<List<ChatRoom>> snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      return ChatRoomCard(currentUser: widget.currentUser, chatRoom: snapshot.data![index]);
                    }
                );
              }
              else{
                return const Center(child: Text("Start New Chat"));
              }
            }
        ),
      ),
    );
  }
}
class ChatRoomCard extends StatefulWidget {
  final ChatRoom chatRoom;
  final UnicoUser currentUser;
  const ChatRoomCard({Key? key, required this.chatRoom, required this.currentUser}) : super(key: key);

  @override
  State<ChatRoomCard> createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  Future<UnicoUser>? toUser;
  DatabaseService database = DatabaseService();
  bool loading = false;

  @override
  void initState(){
    super.initState();
    setState(()=> loading = true);
    toUser =  _getOtherUser();
    setState(()=> loading = false);
  }
  Future<UnicoUser> _getOtherUser() async{
    return await database.getUserFromUserId(userId: widget.chatRoom.getOtherUser(myId: widget.currentUser.uid));
  }

  @override
   Widget build(BuildContext context) {
     return FutureBuilder(
         future: toUser,
         builder: (BuildContext context, AsyncSnapshot<UnicoUser> snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting)
           {return const Loading();}
           else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
             UnicoUser sendToUser = snapshot.data!;
             return loading? const Loading():GestureDetector(
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                       ChatScreen(toUser: sendToUser, currentUser: widget.currentUser,chatRoomId: widget.chatRoom.id,))),
                 child: Container(
                 margin: const EdgeInsets.only(
                     top: 2.0, bottom: 2.0, right: 8.0),
                 padding: const EdgeInsets.symmetric(
                     horizontal: 16.0, vertical: 8.0),
                 decoration: BoxDecoration(
                   color: widget.chatRoom.unreadNumber == 0 ? const Color(
                       0xFFFFEFEE) : Colors.white,
                   borderRadius: const BorderRadius.only(
                     topRight: Radius.circular(20.0),
                     bottomRight: Radius.circular(20.0),),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Row(
                       children: <Widget>[
                         CircleAvatar(
                           radius: 32.0,
                           backgroundImage: sendToUser
                               .userData["profileImageUrl"] != "" ?
                           NetworkImage(sendToUser.userData["profileImageUrl"]) :
                           const AssetImage(
                               "assets/images/default_profile_pic.png") as ImageProvider,
                         ),
                         const SizedBox(width: 9.0),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Text(
                               sendToUser.userData["firstName"] + " " + sendToUser
                                   .userData["lastName"],
                               style: const TextStyle(
                                 color: Colors.grey,
                                 fontSize: 15.0,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             const SizedBox(height: 5.0),
                             SizedBox(
                               width: MediaQuery
                                   .of(context)
                                   .size
                                   .width * 0.5,
                               child: Text(
                                 widget.chatRoom.text,
                                 style: const TextStyle(
                                   color: Colors.blueGrey,
                                   fontSize: 14.0,
                                   fontWeight: FontWeight.w500,
                                 ),
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                     Column(
                       children: <Widget>[
                         Text(
                           widget.chatRoom.messageTime,
                           style: const TextStyle(
                             color: Colors.grey,
                             fontSize: 15.0,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         const SizedBox(height: 5.0),
                         widget.chatRoom.unreadNumber != 0 && widget.chatRoom.sender != widget.currentUser.uid ?
                         Container(
                           width: 40.0,
                           height: 20.0,
                           decoration: BoxDecoration(
                             color: Theme
                                 .of(context)
                                 .primaryColor,
                             borderRadius: BorderRadius.circular(30.0),
                           ),
                           alignment: Alignment.center,
                           child: Text(
                             widget.chatRoom.unreadNumber.toString(),
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 12.0,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         )
                             : const Text(""),
                       ],
                     ),
                   ],
                 ),
               ),
             );
           }
           else{
             return Container();
           }
         }
     );
   }
}
