import 'package:intl/intl.dart';

class ChatRoom{
  List<String> usersId;
  String text;
  DateTime time;
  int unreadNumber;
  String sender;
  String id;

  ChatRoom({required this.text, required this.sender, this.unreadNumber = 0, required this.time, required this.usersId, required this.id});

  bool isMe({required String myId}) => myId != sender? false: true;
  bool isInDate({required DateTime date}) => date.day == time.day && date.month == time.month && date.year == time.year;
  String get messageTime{
    return DateFormat.Hm().format(time);
  }
  String get messageDate{
    return DateFormat("dd-MM-yyyy").format(time);
  }
  String getOtherUser({required String myId}) => usersId[0] == myId? usersId[1]: usersId[0];
}

