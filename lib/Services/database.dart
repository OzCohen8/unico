import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unico/models/chat_room_modal.dart';
import 'package:unico/models/message_modal.dart';
import 'package:unico/models/user_modal.dart';

class DatabaseService extends ChangeNotifier{
  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection("ChatRoom");

  Future<void> createUser({required UnicoUser unicoUser, required uid}) async{
    return await userCollection.doc(uid).set({
      "firstName": unicoUser.userData["firstName"],
      "lastName":  unicoUser.userData["lastName"],
      "posts":  unicoUser.userData["posts"],
      "followers":  unicoUser.userData["followers"],
      "following":  unicoUser.userData["following"],
      "searchHistory":  unicoUser.userData["searchHistory"],
      "profileImageUrl": unicoUser.userData["profileImageUrl"],
    });
  }

  Future setData({required String uid, required String field, required data}) async{
    return await userCollection.doc(uid).update({field: data});
  }

  Future<UnicoUser> getUserFromUserId({required String userId}) async{
    DocumentSnapshot data = await userCollection.doc(userId).get();
    Map<String, dynamic> userData = data.data() as Map<String, dynamic>;
    UnicoUser user = UnicoUser(uid: userId ,data: userData);
    return user;
  }

  Future getUserByUsername({required String username}) async{
    return await userCollection.where("username", isEqualTo: username).get();
  }
  //get users stream
 Stream<QuerySnapshot> get users{
   return userCollection.snapshots();
 }



 String getChatId({required String uid, required String uid2}){
    return checkUidForChatId(uid: uid.toLowerCase(), uid2: uid2.toLowerCase())? uid+"_"+uid2:uid2+"_"+uid;
 }
 bool checkUidForChatId({required String uid, required String uid2}){
    if( uid.substring(0,1).codeUnitAt(0) > uid2.substring(0,1).codeUnitAt(0)){
      return false;
    }
    else if(uid.substring(0,1).codeUnitAt(0) < uid2.substring(0,1).codeUnitAt(0)){
      return true;
    }
    else{
      if(uid.substring(1,).isEmpty){ return true;}
      if(uid2.substring(1,).isEmpty){ return false;}
      return checkUidForChatId(uid: uid.substring(1,), uid2: uid2.substring(2,));
    }
 }

 Future<void> createChatRoom({required String currentUserId, required String userId, required String chatRoomId}) async{
   DocumentSnapshot doc = await chatCollection.doc(chatRoomId).get();
   if (doc.exists) {return ;}
   else {
     return await chatCollection.doc(chatRoomId).set({
       "usersId" : [currentUserId, userId],
       "text" : null,
       "time": DateTime.now(),
       "unreadNumber": 0,
       "sender": null,
     });
   }
  }
  // _deleteChatRoom({required String id}) async{
  //   await chatCollection.doc(id).delete();
  // }
  // deleteChatRooms() async{
  //   QuerySnapshot querySnapshot = await chatCollection.get();
  //   querySnapshot.docs.where(
  //           (data) {
  //         Map<String, dynamic> chatRoomData = data.data() as Map<String, dynamic>;
  //         DateTime time = DateTime.parse(chatRoomData["time"].toDate().toString());
  //         return chatRoomData["sender"] != null && time.difference(DateTime.now())? true:false;
  //       }
  //   ).map((doc) => _deleteChatRoom(id: doc.id));
  // }

 Future<void> addMessage({required String currentUserId, required String userId, required Message message}) async{
    String chatRoomId = getChatId(uid: currentUserId, uid2: userId);
    await chatCollection.doc(chatRoomId).collection("chats").add(message.messageMap).catchError((e)=> print(e.toString()));
    addMessageToChatRoom(chatRoomId: chatRoomId, message: message);
   }
 Future<void> addMessageToChatRoom({required String chatRoomId, required Message message}) async{
    DocumentReference docRef = chatCollection.doc(chatRoomId);
    DocumentSnapshot data = await docRef.get();
    int unreadNumber = data.get("unreadNumber");
    unreadNumber=unreadNumber+1;
    await docRef.update(
        {
          "sender": message.sender.uid,
          "text": message.text,
          "time":message.time,
          "unreadNumber":unreadNumber
        }
    );
}

 Future<void> resetUnread({ required String chatRoomId, required String myId }) async{
    DocumentSnapshot data = await chatCollection.doc(chatRoomId).get();
    String sender = data.get("sender");
    if(sender != myId)
      {
        await chatCollection.doc(chatRoomId).update({"unreadNumber":0});
      }
}

 Map<DateTime,List<Message>> groupDate(List<Message> messages){
    Map<DateTime,List<Message>> listDate= {};
    for (Message message in messages){
      listDate.containsKey(message.time)?
      listDate[message.time]!.add(message): listDate[message.time] = [message];
    }
    return listDate;
  }

 Stream<List<Message>> getConversationMessages({required UnicoUser currentUser,required UnicoUser toUser}){
   String chatRoomId = getChatId(uid: currentUser.uid, uid2: toUser.uid);
    return chatCollection.doc(chatRoomId).collection("chats").orderBy("time").snapshots().map((event) => event.docs.map((data) {
      Map<String, dynamic> messageData = data.data();
      UnicoUser sender;
      messageData["sender"] == currentUser.uid? sender = currentUser: sender = toUser;
      return Message(text: messageData["text"],unread: messageData["unread"],isLiked: messageData["isLiked"], sender: sender, time:
      DateTime.parse(messageData["time"].toDate().toString()));
    }).toList());
   }
 Stream<List<ChatRoom>> getChatRooms({required UnicoUser user}){
    return chatCollection.where("usersId", arrayContains: user.uid).snapshots().map((event) => event.docs.where(
            (data) {
              Map<String, dynamic> chatRoomData = data.data() as Map<String, dynamic>;
              return chatRoomData["sender"] != null? true:false;
            }
    ).map((data) {
      Map<String, dynamic> chatRoomData = data.data() as Map<String, dynamic>;
      DateTime time = DateTime.parse(chatRoomData["time"].toDate().toString());
      List<String> usersId = [chatRoomData["usersId"][0], chatRoomData["usersId"][1]];
      return ChatRoom(text: chatRoomData["text"], sender: chatRoomData["sender"], time: time, usersId: usersId, unreadNumber:  chatRoomData["unreadNumber"], id: data.id);
    }).toList());
  }
  Stream getUnreadNumber({required UnicoUser user}){
    int sum = 0;
    return chatCollection.where("usersId", arrayContains: user.uid).where("sender", isNotEqualTo: user.uid).snapshots().map((event) => event.docs.map((doc)
        {
         sum= sum + int.parse(doc.get("unreadNumber"));
         return sum;
        }));
  }

}