import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:unico/Services/authentication_services.dart';
import 'package:unico/models/user_modal.dart';
import 'package:unico/shared/loading.dart';
import 'package:unico/shared/style.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool isPasswordVisible =false;
  bool isRepeatPasswordVisible =false;
  bool loading = false;
  final double? formTextSize = 14 ;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : KeyboardDismisser(
      gestures: const [GestureType.onTap, GestureType.onHorizontalDragDown],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
          leading: IconButton(
            onPressed: (){widget.toggleView();},
            icon: const Icon(Icons.arrow_back),
          )
        ),
        body: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 30, ),
                children: <Widget>[
                  Image.asset("assets/images/U-symbol.png", width: 500, height: 140),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(child: buildFirstname()),
                      const SizedBox(width: 5,),
                      Flexible(child: buildLastname()),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  buildEmail(),
                  const SizedBox(height: 15,),
                  buildPassword(),
                  const SizedBox(height: 15,),
                  buildRepeatPassword(),
                  const SizedBox(height: 15,),
                  buildPhoneNumber(),
                  const SizedBox(height: 15,),
                  buildSubmit(),
                ]
            ),
          ),
        ),
      )
    );
  }

  Widget buildPassword() => TextFormField(
      controller: passwordController,
      decoration: textInputDecoration.copyWith(
      hintText: "Your password",
        hintStyle:  TextStyle(fontSize: formTextSize),
        labelStyle:  TextStyle(fontSize: formTextSize),
      labelText: "Password",
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: isPasswordVisible ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),),
      ),
    validator: (value){
      if (value!.length < 8)  {return 'Enter at least 8 characters';}
      else {return null;}
    },
    obscureText: !isPasswordVisible,
  );

  Widget buildRepeatPassword() => TextFormField(
    controller: repeatPasswordController,
    decoration: textInputDecoration.copyWith(
      labelText: "Repeat Password",
      labelStyle:  TextStyle(fontSize: formTextSize),
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: isRepeatPasswordVisible ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
        onPressed: () => setState(() => isRepeatPasswordVisible = !isRepeatPasswordVisible),),
    ),
    validator: (value){
      if (value!.length < 8)  {return 'Enter at least 8 characters';}
      else if (value != passwordController.text)  {return "Password don't match";}
      else {return null;}
    },
    obscureText: !isRepeatPasswordVisible,
  );

  String? _validateName({required String? name,required bool isFirst}){
    final String field;
    isFirst ? field= "First" : field= "Last";
    final regExp = RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$");
    if (name!.isEmpty)  {return field+" name required";}
    else if (!regExp.hasMatch(name)) {
      return 'Enter a valid '+field+' name';
    } else {return null;}
  }

  Widget buildFirstname() => TextFormField(
    controller: firstNameController,
    decoration: textInputDecoration.copyWith(
        prefixIcon: const Icon(Icons.person),
        labelText: 'First Name',
        labelStyle:  TextStyle(fontSize: formTextSize),
        suffixIcon: firstNameController.text.isEmpty ? Container(width: 0)
            : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => firstNameController.clear(),
            )
    ),
    validator: (value) {_validateName(name: value, isFirst: true);},
    maxLength: 30,
  );

  Widget buildLastname() => TextFormField(
    controller: lastNameController,
    decoration: textInputDecoration.copyWith(
        prefixIcon: const Icon(Icons.person),
        labelText: 'Last Name',
        labelStyle:  TextStyle(fontSize: formTextSize),
        suffixIcon: lastNameController.text.isEmpty ? Container(width: 0)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => lastNameController.clear(),
        )
    ),
    validator: (value) {_validateName(name: value, isFirst: false);},
    maxLength: 30,
  );

  Widget buildEmail()=> TextFormField(
    controller: emailController,
    decoration:  textInputDecoration.copyWith(
        labelText: "Email",
        hintText: "name@example.com",
        hintStyle:  TextStyle(fontSize: formTextSize),
        labelStyle:  TextStyle(fontSize: formTextSize),
        prefixIcon: const Icon(Icons.mail),
        suffixIcon: emailController.text.isEmpty ? Container(width: 0)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => emailController.clear(),
        )
    ),
    validator: (value){
      final regExp = RegExp( r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');

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

  Widget buildPhoneNumber() => TextFormField(
    controller: phoneNumberController,
    decoration: textInputDecoration.copyWith(
      hintText: "Enter phone number",
      labelText: "Phone Number",
      hintStyle:  TextStyle(fontSize: formTextSize),
      labelStyle:  TextStyle(fontSize: formTextSize),
      prefixIcon: const Icon(Icons.phone_android),
    ),
    validator: (value){
      if(value!.length != 10) {return "Enter valid phone number";}
      else {return null;}
    },
    keyboardType: TextInputType.number,
  );

  Widget buildSubmit() => ElevatedButton	(
  onPressed: () async
  {
    FocusScope.of(context).unfocus();
    if(_formKey.currentState!.validate()){
      setState(() => loading =true);
      _formKey.currentState?.save();
      Map<String, dynamic> data = {"firstName": firstNameController.text};
      data["lastName"] = lastNameController.text;
      data["email"] = emailController.text;
      data["password"] = passwordController.text;
      UnicoUser user = UnicoUser(uid: "NewUser", data: data);
      final provider = Provider.of<AuthServices>(context, listen: false);
        await provider.signUp(
        newUnicoUser: user,
        // phoneCredential: PhoneAuthProvider(passwordController.text),
        context: context,
      );
      setState(() => loading = false);
    }
  },
  child: const Text("Submit"),
  );
}

