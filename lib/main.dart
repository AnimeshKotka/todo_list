import 'package:flutter/material.dart';
import './firebasea/auth.dart';
// import 'package:flutter/services.dart';
import './root_page.dart';
import './firebasea/auth_provider.dart';

void main() {
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
        auth: Auth(),
        child: MaterialApp(
          title: 'Personal Expanses',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'Montserrat',
            textTheme: ThemeData.light().textTheme.copyWith(
                  title: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  button: TextStyle(color: Colors.white),
                ),
          ),
          home: RootPage(),
        ));
  }
}
// TODO : add database to store users data in home page => DONE