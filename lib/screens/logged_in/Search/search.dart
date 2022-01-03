import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unico/Services/database.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/Search/setting_form.dart';
import 'package:unico/screens/logged_in/account.dart';
import 'package:unico/shared/loading.dart';

class Search extends StatefulWidget {
  final Color iconsColor;
  final UnicoUser currentUser;
  const Search({Key? key, required this.iconsColor,required this.currentUser}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool loading = false;
  Future<List<UnicoUser>>? recentUsers;

  @override
  void initState() {
    setState(()=> loading = true);
    recentUsers = widget.currentUser.recentUserSearch;
    setState(()=> loading = false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  loading ? const Loading() : StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().users,
      builder: (context, snapshot) {
        List<UnicoUser> users = [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        else if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs){
            if(doc.id != widget.currentUser.uid){
            users.add(UnicoUser(uid: doc.id, data: doc.data() as Map<String, dynamic>));}
            }
          return FutureBuilder(
              future: recentUsers!,
              builder: (BuildContext context, AsyncSnapshot<List<UnicoUser>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: Image.asset("assets/images/appbar-Logo.png",),
                        title: Text(
                          "Unico",
                          style: TextStyle(fontFamily: "Pacifico", color: Theme
                              .of(context)
                              .primaryColor),),
                        actions: [
                          IconButton(
                              onPressed: () =>
                                  _showSettingsPanel(context: context),
                              icon: Icon(Icons.settings,
                                color: widget.iconsColor,)),
                          IconButton(icon: Icon(Icons.search,
                              color: widget.iconsColor),
                              onPressed: () {
                                showSearch(context: context,
                                    delegate: DataSearch(users: users,
                                        iconsColor: widget.iconsColor,
                                        currentUser: widget.currentUser,
                                        recentUsers: snapshot.data!));
                              })
                        ],
                      ),
                      drawer: const Drawer(),
                      body: Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  const <Widget>[
                              Text("Search", style: TextStyle(fontSize: 24),),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text("here the user will see designs which he may like acording to his designs, last searches and feed"),
                              ),
                            ],
                          ),
                        ),
                      )
                  );
                }
                else if (snapshot.connectionState == ConnectionState.waiting)
                {return const Loading();}
                else{
                  return Container();
                }
              }
          );
        }
        else {return const Center(child: Text("Something went wrong"),);}
      }
    );
  }
  void _showSettingsPanel({required context}){
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: const SettingsForm(),
      );
    });
  }
}

class DataSearch extends SearchDelegate<String?>{
  final List<UnicoUser> users;
  final Color iconsColor;
  final UnicoUser currentUser;
  List<UnicoUser>? recentUsers;
  DatabaseService database =DatabaseService();
  DataSearch({required this.users, required this.iconsColor,required this.currentUser, required this.recentUsers});
  @override
  List<Widget>? buildActions(BuildContext context) {
    // actions for app bar
    return [IconButton(
        onPressed: () {
          if(query.isEmpty){close(context, null);}
          else {
            query = "";
            showSuggestions(context);}
          },
      icon: const Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // leading icon on the left of the app bar
    return IconButton(onPressed: () {close(context, null);},
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,));
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some results based on the selection
    return Container();}

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final List<UnicoUser> suggestions = query.isEmpty?recentUsers!: users.where((user) => user.userData["firstName"].toLowerCase().startsWith(query.toLowerCase())).toList();
    return buildSuggestionsSuccess(suggestions);
  }

  Widget buildSuggestionsSuccess(List<UnicoUser> suggestions) => ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context,index) {
        final suggestion = suggestions[index];
        final queryText = suggestion.userData["firstName"].substring(0,query.length);
        final remainingText = suggestion.userData["firstName"].substring(query.length);
        return ListTile(
          onTap: (){
            query = suggestion.userData["firstName"];
            currentUser.addToSearchHistory(uid: suggestion.uid);
            Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context)=> Account(currentUser: suggestion,iconsColor: iconsColor,isMe: false,myAccount: currentUser,),));
          },
          leading: suggestion.userData["profileImageUrl"] != ""? CircleAvatar(
            backgroundImage: NetworkImage(suggestion.userData["profileImageUrl"]),
            radius: 18,
            backgroundColor: Colors.transparent,
          ): const Icon(Icons.person),
          title: RichText(
            text: TextSpan(text: queryText,
              style:  TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor, fontSize: 18),
              children: [
                TextSpan(text: remainingText,
                    style: const TextStyle(color: Colors.grey, fontSize: 18), )
              ],
            ),
          ),
          subtitle: const Text("type"),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: (){
              currentUser.removeFromSearchHistory(uid: suggestion.uid);

            },
          ),
        );
      },
  );
}
