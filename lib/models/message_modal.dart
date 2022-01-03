import 'package:intl/intl.dart';
import 'package:unico/models/user_modal.dart';

class Message{
  String text;
  UnicoUser sender;
  DateTime time;
  bool isLiked;
  bool unread;

  Message({required this.text, required this.sender, this.unread = false, this.isLiked = false, required this.time});

  Map<String,dynamic> get messageMap{
    return {"text": text, "sender": sender.uid, "time": time, "isLiked": isLiked, "unread": unread };
  }

  bool isMe({required String myId}) => myId != sender.uid? false: true;
  bool isInDate({required DateTime date}) => date.day == time.day && date.month == time.month && date.year == time.year;
  String get messageTime{
    return DateFormat.Hm().format(time);
  }
  String get messageDate{
    return DateFormat("dd-MM-yyyy").format(time);
  }

  @override
  String toString() {
    return "message: [Text: $text, Time: ${time.toString()}]";
  }
}

