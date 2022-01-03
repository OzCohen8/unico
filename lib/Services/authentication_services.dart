import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:unico/Services/database.dart';
import 'package:unico/models/user_modal.dart';

class AuthServices extends ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // get unico user
  // UnicoUser? getUnicoUser(){
  //   return _userFromFirebaseUser(_auth.currentUser!);
  // }
  // create user object base on FirebaseUser
  Future<UnicoUser?> _userFromFirebaseUser(User? user) async{
  return user != null ? await DatabaseService().getUserFromUserId(userId: user.uid) : null;}

  // auth change user stream
  Stream<UnicoUser?> get unicoUser {
    return _auth.authStateChanges().asyncMap(_userFromFirebaseUser);
  }

  //sign in with email & password
  Future signInEmailPassword({required String email, required String password, required BuildContext context}) async{
    try{
      FocusScope.of(context).unfocus();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Login Successful");
    } on FirebaseAuthException catch (e) { Fluttertoast.showToast(msg: e.message!,toastLength: Toast.LENGTH_LONG);}
  }

  // sign up with email & password
  Future signUp({required UnicoUser newUnicoUser, required BuildContext context}) async{
    try{
      await _auth.createUserWithEmailAndPassword(email: newUnicoUser.userData["email"], password: newUnicoUser.userData["password"]);
      final User user = _auth.currentUser!;
      // user.updateDisplayName(firstname+ " "+ lastname);
      // // user.updatePhoneNumber(phoneCredential); , required PhoneAuthCredential phoneCredential
      // user.updatePhotoURL(null);
      print("Signed up user\n"+ user.toString());

      // create a new document for the user with the uid
      await DatabaseService().createUser(unicoUser: newUnicoUser, uid: user.uid);
      // create a snack bar which declares that the sign up succeeded
      final message = "Welcome ${user.displayName}\nplease confirm your account";
      final snackBar = SnackBar(
        content: Text(message,style: const TextStyle(fontSize: 20),),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return true;
    } on FirebaseAuthException catch (e) {Fluttertoast.showToast(msg: e.message!,toastLength: Toast.LENGTH_LONG);}
  }

  // sign in with google
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential).then((value) =>
          DatabaseService().createUser(uid: value.user!.uid, unicoUser: UnicoUser(uid: value.user!.uid, data: {})));
    } catch (e){
      print(e.toString());
    }
    notifyListeners();
  }

  // reset password with email
  Future<bool> resetPassword({required String email, required BuildContext context}) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      return true;
    }
    on FirebaseAuthException catch (e) {Fluttertoast.showToast(msg: e.message!,toastLength: Toast.LENGTH_LONG); return false;}
  }

  // sign out
  Future logout() async{
    try{
    await _auth.signOut();
    await googleSignIn.disconnect();
    }catch(e){
      print(e.toString());
    }

  }
}

