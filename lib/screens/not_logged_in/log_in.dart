import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:unico/Services/authentication_services.dart';
import 'package:unico/shared/loading.dart';
import 'package:unico/shared/style.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailForPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : KeyboardDismisser(
      gestures: const [GestureType.onTap, GestureType.onHorizontalDragDown],
      child: Scaffold(
        body: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 5),
                children: <Widget>[
                  Image.asset("assets/images/Logo3.jpg", width: 500, height: 300),
                  buildEmail(),
                  const SizedBox(height: 10,),
                  buildPassword(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:<Widget> [
                        TextButton(onPressed: () => _showResetPasswordPanel(context: context), child: const Text("Forgot Password?",style: TextStyle(fontSize: 11),))]),
                  ElevatedButton(onPressed: () {logUserIn();}, child: const Text("Log - In")),
                  const SizedBox(height: 10,),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          onPrimary: Colors.white,
                          minimumSize: const Size(double.infinity, 45)
                      ),
                      onPressed: () {
                        final provider = Provider.of<AuthServices>(context, listen: false);
                        provider.googleLogin();
                      },
                      icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                      label: const Text("Log In with Google")
                  ),
                  const SizedBox(height: 10,),
                  Row(children: const <Widget>[
                    Expanded(child: Divider(color: Colors.black54, thickness: 0.7, indent: 8, endIndent: 8,)),
                    Text("OR", style: TextStyle(color: Colors.black54),),
                    Expanded(child: Divider(color: Colors.black54, thickness: 0.7, indent: 8, endIndent: 8,)),
                      ]
                  ),
                  TextButton(onPressed: () {widget.toggleView();}, child: const Text("Sign Up")),
                ]
            )
          ),
        ),
      ),
    );
  }

  Widget buildEmail()=> TextFormField(
    controller: emailController,
    decoration:  textInputDecoration.copyWith(
        labelText: "Email",
        hintText: "name@example.com",
        prefixIcon: const Icon(Icons.mail),
        suffixIcon: emailController.text.isEmpty ? Container(width: 0)
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => emailController.clear(),
              )
    ),
    validator: (value){
      final regExp = RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
      if (value!.isEmpty) {
        return 'Enter an email';
      } else if (!regExp.hasMatch(value)) {
        return 'Enter a valid email';
      } else {
        return null;
      }
    },
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.done,
  );

  Widget buildEmailForPasswordReset()=> TextFormField(
    controller: emailForPasswordController,
    decoration:  textInputDecoration.copyWith(
        labelText: "Email",
        hintText: "name@example.com",
        prefixIcon: const Icon(Icons.mail),
        suffixIcon: emailForPasswordController.text.isEmpty ? Container(width: 0)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => emailForPasswordController.clear(),
        )
    ),
    validator: (value){
      final regExp = RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
      if (value!.isEmpty) {
        return 'Enter an email';
      } else if (!regExp.hasMatch(value)) {
        return 'Enter a valid email';
      } else {
        return null;
      }
    },
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.done,
  );

  Widget buildPassword() => TextFormField(
    controller: passwordController,
    decoration: textInputDecoration.copyWith(
      hintText: "Your password",
      labelText: "Password",
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: isPasswordVisible ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
      ),
    ),
    validator: (value) => value!.isEmpty ? "Password required" : null,
    obscureText: !isPasswordVisible,
  );


  void logUserIn() async{
    if(_formKey.currentState!.validate()) {
      setState(()=> loading = true);
      _formKey.currentState?.save();
      final provider = Provider.of<AuthServices>(context, listen: false);
       await provider.signInEmailPassword(email: emailController.text, password: passwordController.text,context: context);
      passwordController.clear();
      setState(()=> loading = false);
    }
  }

  void _showResetPasswordPanel({required context}){
    showModalBottomSheet <void>(context: context, builder: (BuildContext context){
      return Form(
        key: _resetFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              buildEmailForPasswordReset(),
              ElevatedButton(onPressed: () async {
                if(_resetFormKey.currentState!.validate()) {
                  AuthServices _auth = AuthServices();
                  bool check = await _auth.resetPassword(email: emailForPasswordController.text, context: context);
                  if(check){
                    Fluttertoast.showToast(msg:"A password reset link has been sent to ${emailForPasswordController.text}",toastLength: Toast.LENGTH_LONG);
                    emailForPasswordController.clear();
                  }
                }
              }, child: const Text("Reset Password")),
            ],
          ),
        ),
      );
    });
  }

}

