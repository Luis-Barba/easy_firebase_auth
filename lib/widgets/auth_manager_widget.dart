import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/auth_state.dart';

class AuthManagerWidget extends StatefulWidget {
  final Widget splashScreen, loginScreen, mainScreen;
  final Future Function(AuthMethod) actionsBeforeLogIn;
  final Future Function(AuthMethod, FirebaseUser) actionsAfterLogIn;
  final Future Function(FirebaseUser) actionsBeforeLogOut;
  final Future Function() actionsAfterLogOut;

  AuthManagerWidget(
      {Key key,
      this.splashScreen,
      @required this.loginScreen,
      @required this.mainScreen,
      this.actionsBeforeLogIn,
      this.actionsAfterLogIn,
      this.actionsBeforeLogOut,
      this.actionsAfterLogOut})
      : super(key: key);

  @override
  _AuthManagerWidgetState createState() => _AuthManagerWidgetState();
}

class _AuthManagerWidgetState extends State<AuthManagerWidget> {
  @override
  Widget build(BuildContext context) {
    AuthState authModel = Provider.of<AuthState>(context);
    authModel.actionsBeforeLogIn = widget.actionsBeforeLogIn;
    authModel.actionsAfterLogIn = widget.actionsAfterLogIn;
    authModel.actionsBeforeLogOut = widget.actionsBeforeLogOut;
    authModel.actionsAfterLogOut = widget.actionsAfterLogOut;

    switch (authModel.authStatus) {
      case AuthStatus.CHECKING:
        return widget.splashScreen != null ? widget.splashScreen : Scaffold();

      case AuthStatus.NOT_LOGGED:
        return widget.loginScreen;

      case AuthStatus.LOGGED:
        return widget.mainScreen;

      default:
        return null;
    }
  }
}
