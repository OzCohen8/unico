import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:unico/Services/database.dart';
import 'package:unico/models/user_modal.dart';


class Storage{
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;
  final UnicoUser user;
  String? profileImagePath;
  DatabaseService database = DatabaseService();
  Storage({required this.user}){
    profileImagePath = "${user.uid}/images/profileIMG/";
  }

  Future<void> uploadFile({required String filePath, required String fileName, required bool isImage}) async{
    File file = File(filePath);
    try{
      if(isImage){
      String path = "${user.uid}/images/";
      deleteFile(filePath: path);
      await _storage.ref(path + fileName).putFile(file);}
      else
      {await _storage.ref("${user.uid}/posts/$fileName").putFile(file);}
    }
    on firebase_core.FirebaseException catch(e) {print(e);}
  }

  Future<void> uploadProfileImg({required String filePath, required String fileName}) async{
    File file = File(filePath);
    try {
      firebase_storage.ListResult prevImg = await getElementsOfDirectory(directoryPath: profileImagePath!);
      if(prevImg.items.isNotEmpty)
      {
        String path = prevImg.items.first.fullPath;
        deleteFile(filePath: path);
      }
      await _storage.ref(profileImagePath! + fileName).putFile(file);
      await database.setData(uid: user.uid, field: "profileImageUrl", data: await profileImgURL);
    }
    on firebase_core.FirebaseException catch(e) {print(e);}
  }
  Future<void> deleteFile({required String filePath}) async{
    try{ await _storage.ref(filePath).delete();}
    on firebase_core.FirebaseException catch(e) {print(e);}
  }

  Future<firebase_storage.ListResult>  getElementsOfDirectory({required String directoryPath}) async {
    return await _storage.ref(directoryPath).listAll();
  }


  Future<String> downloadURL(String filePath) async {
    return await _storage.ref(filePath).getDownloadURL();
  }

  Future<String> get profileImgURL async{
    firebase_storage.ListResult image = await getElementsOfDirectory(directoryPath: profileImagePath!);
    String path = image.items.first.fullPath;
    return downloadURL(path);
  }
}
