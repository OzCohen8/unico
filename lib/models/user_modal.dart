import 'package:unico/Services/database.dart';

class UnicoUser{
  Map<String, dynamic> userData = {};
  final String uid;
  bool? isVerified;
  DatabaseService database = DatabaseService();

  UnicoUser({required this.uid, required Map<String, dynamic> data}){
    data["firstName"] != null ? userData["firstName"] = data["firstName"]: userData["firstName"] = "";
    data["lastName"] != null ? userData["lastName"] = data["lastName"]: userData["lastName"] = "";
    data["email"] != null ? userData["email"] = data["email"]: userData["email"] = "";
    data["following"] != null ? userData["following"] = data["following"]: userData["following"] = [];
    data["followers"] != null ? userData["followers"] = data["followers"]: userData["followers"] = [];
    data["posts"] != null ? userData["posts"] = data["posts"]: userData["posts"] = [];
    data["password"] != null ? userData["password"] = data["password"]: userData["password"] = "";
    data["password"] != null ? userData["password"] = data["password"]: userData["password"] = "";
    data["searchHistory"] != null ? userData["searchHistory"] = data["searchHistory"]: userData["searchHistory"] = <String>[];
    data["profileImageUrl"] != null ? userData["profileImageUrl"] = data["profileImageUrl"]: userData["profileImageUrl"] = "";
  }

  int get followersNumber{
    List followers = userData["followers"];
    return followers.length;
  }
  Future<UnicoUser> addFollowing({required UnicoUser userToFollow}) async{
    List followers = userToFollow.userData["followers"];
    List following = userData["following"];
    following.add(userToFollow.uid);
    followers.add(uid);
    userData["following"] = following;
    await database.setData(uid: userToFollow.uid, field: "followers", data: followers);
    await database.setData(uid: uid,field: "following", data: following);
    return await database.getUserFromUserId(userId: userToFollow.uid);
  }
  bool isFollowing({required String uid}){
    return userData["following"].contains(uid) ? true : false;
  }
  Future<UnicoUser> removeFollowing({required UnicoUser userToFollow}) async{
    userData["following"].remove(userToFollow.uid);
    userToFollow.userData["followers"].remove(uid);
    userData["following"] = userData["following"];
    await database.setData(uid: userToFollow.uid, field: "followers", data: userToFollow.userData["followers"]);
    await database.setData(uid: uid,field: "following", data: userData["following"]);
    return await database.getUserFromUserId(userId: userToFollow.uid);
  }

  void addToSearchHistory({required String uid}){
    if(!userData["searchHistory"].contains(uid)){
      userData["searchHistory"].add(uid);
      database.setData(uid: this.uid, field: "searchHistory", data: userData["searchHistory"]);
    }
}
  void removeFromSearchHistory({required String uid}){
    userData["searchHistory"].remove(uid);
    database.setData(uid: this.uid, field: "searchHistory", data: userData["searchHistory"]);
  }
  Future<List<UnicoUser>> get recentUserSearch async{
    List<UnicoUser> recentUsers = [];
    for(String id in userData["searchHistory"]){
      recentUsers.add(await database.getUserFromUserId(userId: id));
    }
    return recentUsers;
  }

  Future<UnicoUser> updateUser() async{
    return await database.getUserFromUserId(userId: uid);
  }


}