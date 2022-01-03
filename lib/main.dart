import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unico/Services/authentication_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unico/Services/database.dart';

import 'package:unico/screens/authentication_wrapper.dart';
import 'package:unico/shared/style.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const UnicoApp());
}

class UnicoApp extends StatelessWidget {
  const UnicoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<AuthServices>(create:  (context) => AuthServices(),),
      ChangeNotifierProvider<DatabaseService>(create:  (context) => DatabaseService(),)
    ],
      child: ChangeNotifierProvider(
          create:  (context) => ThemeProvider(),
        builder:  (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);
            return MaterialApp(
              themeMode: themeProvider.themeMode,
              theme:  UnicoTheme.lightTheme,
              darkTheme: UnicoTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: '/AuthenticationWrapper',
              routes: {
                '/AuthenticationWrapper': (context) => const AuthenticationWrapper(),
              }
          );
        },
      ),
    );
  }
}

