import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:unico/Services/authentication_services.dart';
import 'package:unico/Services/database.dart';
import 'package:unico/Services/notification_api.dart';

import 'package:unico/Services/storage_service.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/chat/chat_screen.dart';
import 'package:unico/shared/loading.dart';

import 'package:unico/shared/style.dart';

class Account extends StatefulWidget {
  UnicoUser currentUser;
  final UnicoUser? myAccount;
  final DatabaseService database = DatabaseService();
  final Color iconsColor;
  final bool isMe;
  Account({Key? key, required this.currentUser, required this.iconsColor, required this.isMe, this.myAccount}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool loading = false;
  Storage? storage;
  Future<String>? profileImageFuture;
  Future<firebase_storage.ListResult>? postsFuture;

  @override
  void initState() {
    super.initState();
    setState(()=> loading = true);
    storage = Storage(user: widget.currentUser);
    postsFuture = _getPosts();
    setState(()=> loading = false);
  }

  Future<firebase_storage.ListResult> _getPosts() async =>
      await storage!.getElementsOfDirectory(directoryPath: "${widget.currentUser.uid}/posts");

  @override
  Widget build(BuildContext context) {
    DatabaseService database = DatabaseService();
    return loading ? const Loading() : Scaffold(
      appBar: widget.isMe ?
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Image.asset("assets/images/appbar-Logo.png",),
        title: Text("Unico", style:TextStyle(fontFamily:"Pacifico",color: Theme.of(context).primaryColor),),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications,color: widget.iconsColor)),
          IconButton(onPressed: () => _showSettingsPanel(context: context, storage: storage!), icon: Icon(Icons.view_headline,color: widget.iconsColor)),
        ],
      ) :
      AppBar(
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          !loading?
          widget.myAccount!.isFollowing(uid: widget.currentUser.uid)?
          TextButton.icon(onPressed: () async{
            setState(()=> loading = true);
            UnicoUser user = await widget.myAccount!.removeFollowing(userToFollow: widget.currentUser);
            setState(() {widget.currentUser = user; loading = false;});
          },
              label: const Text("UnFollow"), icon: const Icon(Icons.remove),
                  style: TextButton.styleFrom(primary:widget.iconsColor ==Colors.grey ? Colors.white: Colors.blue),):
          TextButton.icon(onPressed: () async{
            setState(()=> loading = true);
            UnicoUser user = await widget.myAccount!.addFollowing(userToFollow: widget.currentUser);
            setState(() {widget.currentUser = user; loading = false;});
          },
            label: const Text("Follow"), icon: const Icon(Icons.add),
            style: TextButton.styleFrom(primary:widget.iconsColor ==Colors.grey ? Colors.white: Colors.blue),):
              const Loading()
        ],
        title: Text(widget.currentUser.userData["firstName"]),

      ),
      drawer: const Drawer(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // circle avatar future builder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDataCard(title: "Rating", data: "10/10"),
                Column(
                  children: [
                    CircleAvatar(
                backgroundImage: widget.currentUser.userData["profileImageUrl"] != ""?
                NetworkImage(widget.currentUser.userData["profileImageUrl"]):
                const AssetImage("assets/images/default_profile_pic.png") as ImageProvider,
                      radius: 55,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 5,),
                    const Text("Celebrity"),
                    const SizedBox(height: 5,),
                    widget.isMe ? Container():OutlinedButton(
                        onPressed: (){
                          String chatRoomId = database.getChatId(uid: widget.myAccount!.uid, uid2:widget.currentUser.uid);
                          database.createChatRoom(currentUserId: widget.myAccount!.uid, userId: widget.currentUser.uid, chatRoomId: chatRoomId);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> ChatScreen(currentUser: widget.myAccount!,toUser: widget.currentUser,chatRoomId: chatRoomId,)));
                        },
                        child: const Text("Message")),
                  ],
                ),
                buildDataCard(title: "Followers", data: widget.currentUser.followersNumber.toString()),
              ],
            ),
            Divider(color: widget.iconsColor, thickness: 0.6, indent: 8, endIndent: 8,),
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: FutureBuilder(
                  future: postsFuture,
                    builder: (BuildContext context, AsyncSnapshot<firebase_storage.ListResult> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                      if(snapshot.data!.items.isEmpty)
                        {return const Center(child: Text("no designs yet"));}
                      else{
                      return Container(
                        padding:  const EdgeInsets.symmetric(horizontal: 4),
                        child: buildGridView(images: snapshot.data!, storage: storage!)
                      );
                    }
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting)
                      {return const Loading();}
                    else{return const Center(child: Text("no designs yet"));}
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridView({required firebase_storage.ListResult images, required Storage storage}) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4,
    ),
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
    itemCount: images.items.length,
    itemBuilder: (context, index){
      final image = images.items[index];
      return buildPost(image: image,storage: storage, filePath: image.fullPath);
    },
  );
  Widget buildPost({required firebase_storage.Reference image, required Storage storage, required String filePath}) => Container(
      padding: const EdgeInsets.all(1),
      child: GridTile(
      child:  FutureBuilder(
        future: storage.downloadURL(filePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
            return buildImageCard(snapshot.data!);
          }
          else if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
          {return const Loading();}
          return Container();
        },
    ),
  )
  );
  Widget buildImageCard(String imageURL) => Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Ink.image(image: NetworkImage(imageURL),
        height: 240,
        fit: BoxFit.cover,
        child: InkWell(
          onTap: () {},
        ),
        )
      ],
    ),

  );

  Widget buildDataCard({required String title, required String data})=> Card(
    elevation: 0,
    color: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          Text(title,
          style: const TextStyle(fontSize: 14),),
          const SizedBox(height: 12,),
          Text(data,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        ],
      ),
    ),
  );

  void _showSettingsPanel({required context, required Storage storage}){
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Night Mode: "),
                  ChangeThemeButtonWidget(),
                ],
              ),
              ElevatedButton(
                  onPressed:(){_updateProfileImg(storage: storage);},
                  child: const Text("Upload Image")),
              TextButton(
                child: const Text("Logout"),
                onPressed: () {
                  final provider = Provider.of<AuthServices>(context, listen: false);
                  provider.logout();
                },
              ),
              TextButton(
                child: const Text("show"),
                onPressed: () async {
                  await NotificationApi.showNotification(
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
    });
  }

  void _updateProfileImg({required Storage storage}) async {
      final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ["png", "jpg"]
      );
      if (result == null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No image uploaded")));
      }
      else{
        setState(()=> loading = true);
        Navigator.pop(context);
        final path =result.files.single.path!;
        final fileName= result.files.single.name;
        await storage.uploadProfileImg(filePath: path, fileName: fileName).then((value) => print("Profile image uploaded!"));
        UnicoUser updated = await widget.currentUser.updateUser();
        setState(()=> loading = false);
        setState(() => widget.currentUser = updated);
      }
    }
}

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(value: themeProvider.isDarkMode,onChanged: (value) {
      final provider = Provider.of<ThemeProvider>(context, listen: false);
      provider.toggleTheme(value);
    },);
  }
}