import 'package:easy_firebase_auth/easy_firebase_auth.dart';
import 'package:easy_firebase_auth/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends StatelessWidget {
  final int splashScreenDurationMillis;
  final Widget child;

  const AuthProvider(
      {Key key, this.splashScreenDurationMillis, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AuthState(splashScreenDurationMillis: splashScreenDurationMillis),
      child: child,
    );
  }
}
