import 'package:flutter/material.dart';
import './firebasea/auth.dart';
import './home_page.dart';
import './firebasea/login_page.dart';
import './firebasea/auth_provider.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  String _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final BaseAuth auth = AuthProvider.of(context).auth;
    try{
      auth.currentUser().then((String userId) {
        setState(() {
          authStatus = (userId == null) ? AuthStatus.notSignedIn : AuthStatus.signedIn;
        });
        _userId = userId;
      });
    } catch(e){
      print(e.toString());
    }
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {

    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return  LoginPage(
         
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return HomePage(
          userId: _userId,
         onSignedOut: _signedOut,
        );
    }
    return null;
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}