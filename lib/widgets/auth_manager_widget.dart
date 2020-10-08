import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/auth_state.dart';

class AuthManagerWidget extends StatefulWidget {
  final Widget splashScreen, notLoggedScreen, loggedScreen;
  final Future Function(AuthMethod, User) actionsAfterLogIn;
  final Future Function(User) actionsBeforeLogOut;

  AuthManagerWidget(
      {Key key,
      @required this.splashScreen,
      @required this.notLoggedScreen,
      @required this.loggedScreen,
      this.actionsAfterLogIn,
      this.actionsBeforeLogOut})
      : super(key: key);

  @override
  _AuthManagerWidgetState createState() => _AuthManagerWidgetState();
}

class _AuthManagerWidgetState extends State<AuthManagerWidget> {
  @override
  Widget build(BuildContext context) {
    AuthState authModel = Provider.of<AuthState>(context);
    authModel.actionsAfterLogIn = widget.actionsAfterLogIn;
    authModel.actionsBeforeLogOut = widget.actionsBeforeLogOut;

    switch (authModel.authStatus) {
      case AuthStatus.CHECKING:
        return widget.splashScreen;

      case AuthStatus.NOT_LOGGED:
        return widget.notLoggedScreen;

      case AuthStatus.LOGGED:
        return widget.loggedScreen;

      default:
        return null;
    }
  }
}
