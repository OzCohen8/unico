import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unico/Services/notification_api.dart';
import 'package:unico/models/user_modal.dart';

import 'package:unico/screens/logged_in/account.dart';
import 'package:unico/screens/logged_in/home.dart';
import 'package:unico/screens/logged_in/new_design.dart';
import 'package:unico/screens/logged_in/Search/search.dart';

import 'package:unico/shared/style.dart';

class LoggedInWrapper extends StatefulWidget {
  final UnicoUser currentUser;
  const LoggedInWrapper({Key? key, required this.currentUser}) : super(key: key);

  @override
  _LoggedInWrapperState createState() => _LoggedInWrapperState();
}

class _LoggedInWrapperState extends State<LoggedInWrapper> {
  int currentIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //
  //   NotificationApi.init();
  //   listenNotifications();
  // }
  // void listenNotifications() =>
  //     NotificationApi.onNotifications.stream.listen((onClickedNotification));
  // void onClickedNotification(String? payload) =>
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ));

  @override
  Widget build(BuildContext context) {
            Color iconsColor;
            Provider.of<ThemeProvider>(context).isDarkMode?iconsColor =Colors.white:iconsColor =Colors.grey;
            final List<Widget> screens =  [
                Home(iconsColor: iconsColor,currentUser: widget.currentUser),
                Search(iconsColor: iconsColor,currentUser: widget.currentUser,),
                const NewDesign(),
                const Center(child: Text("Status"),),
                Account(currentUser: widget.currentUser,iconsColor: iconsColor,isMe: true,),
              ];
          return Scaffold(
              body: IndexedStack(
                    index: currentIndex,
                    children: screens,
                  ),
              bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.blue,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white38,
                    currentIndex: currentIndex,
                    iconSize: 25,
                    showUnselectedLabels: false,
                    onTap: (index) => setState(() => currentIndex =index),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: "Search",
                      ),
                      BottomNavigationBarItem(
                      icon: Icon(Icons.add_box_outlined),
                      label: "New Design",
                      ),
                      BottomNavigationBarItem(
                      icon: Icon(Icons.add_shopping_cart),
                      label: "Orders",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: "Account",
                      ),
                    ],
                      ),

    );
          }
    }

