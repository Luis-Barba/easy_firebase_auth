import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_firebase_auth/easy_firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      autoSignInAnonymously: false,
      splashScreenDurationMillis: 500,
      child: MaterialApp(
          home: AuthManagerWidget(
        splashScreen: SplashScreen(),
        loggedScreen: LoggedScreen(),
        notLoggedScreen: NotLoggedScreen(),
        actionsAfterLogIn: (method, user) async {
          // Initialize user data here
        },
        actionsBeforeLogOut: (user) async {
          // Stop listeners, remove notification tokens...
        },
      )),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "SPLASH SCREEN",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class LoggedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthState authState = Provider.of(context);
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${authState.uid}\nis anonymous: ${authState.isAnonymous}\nname: ${authState.name}", textAlign: TextAlign.center,),
              RaisedButton(
                onPressed: () {
                  authState.signOut();
                },
                child: Text('Sign out'),
              ),
              RaisedButton(
                onPressed: () {
                  authState.signInWithEmail("l@g.com", "123456");
                },
                child: Text('Reauthenticate with email'),
              ),
              RaisedButton(
                onPressed: () {
                  authState.signInGoogle();
                },
                child: Text('Reauthenticate with google'),
              ),
              RaisedButton(
                onPressed: () {
                  authState.changeName("Name ${DateTime.now().millisecondsSinceEpoch}");
                },
                child: Text('Change name'),
              ),
            ],
          ),
        ));
  }
}

class NotLoggedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can set your custom strings
    // you can add the privacy of your app with markdown with the necessary links
    AuthStrings authStrings = AuthStrings.spanish(
        privacyMarkdown:
            "Al continuar aceptas la [política de privacidad](https://myPrivacyUrl.com) "
            "y las [condiciones de servicio](https://myTermsUrl.com).");

    return LoginScreen(
      authStrings: authStrings,
      backgroundColor: Colors.purple,
      expandedWidget: Center(
        child: Container(
          height: 200,
          width: 300,
          color: Colors.red,
        ),
      ),
    );
  }
}
