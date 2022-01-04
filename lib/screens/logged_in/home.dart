import 'package:flutter/material.dart';
import 'package:unico/Services/notification_api.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/chat/chat.dart';


class Home extends StatefulWidget {
   final Color iconsColor;
   final UnicoUser currentUser;
   const Home({Key? key, required this.iconsColor, required this.currentUser}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // UnicoUser user = Provider.of<AuthServices>( context, listen: false).getUnicoUser()!;
    return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Image.asset("assets/images/appbar-Logo.png",),
                title: Text("Unico", style:TextStyle(fontFamily:"Pacifico",color: Theme.of(context).primaryColor),),
                actions: [
                  IconButton(onPressed: (){}, icon: Icon(Icons.notifications,color: widget.iconsColor,)),
                  IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> ChatHome(currentUser: widget.currentUser,)));}, icon: Icon(Icons.send_rounded, color: widget.iconsColor,)),
                ],
            ),
              body: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:   <Widget>[
                  const Text("Home", style: TextStyle(fontSize: 24),),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("here the user will see all the lasts designs posted by accounts he follows"),
                  ),
                  TextButton(
                    child: const Text("show"),
                    onPressed: () {
                       NotificationApi.showNotification(
                          title:  "Oz Cohen",
                          body: "Hey!! this is my first Notification!",
                          payload: "oz.ss"
                      );
                    },
                  ),
                ],
              ),
            ),
            );
            }
  }

