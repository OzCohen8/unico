import 'package:flutter/material.dart';
import 'package:unico/Services/authentication_services.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/screens/logged_in/logged_in_wrapper.dart';
import 'package:unico/screens/not_logged_in/authenticate.dart';
import 'package:unico/shared/loading.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: AuthServices().unicoUser,
          builder: (context, AsyncSnapshot<UnicoUser?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Loading();}
            // || firebaseUser != null
            else if(snapshot.hasData ){
              return LoggedInWrapper(currentUser: snapshot.data!,);}
            else if (snapshot.hasError){
              return const Center(child: Text("Something went wrong"),);}
            else {
              return const Authenticate();}
          },
        )
    );
  }
}
