import 'package:flutter/material.dart';
import 'package:easy_firebase_auth/widgets/buttons/sign_in_button.dart';

class GoogleSignInButton extends StatelessWidget {
  final double? height, width;
  final String text;
  final bool darkMode;
  final VoidCallback? onPressed;
  final bool centerText;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  GoogleSignInButton(
      {this.height,
      this.width,
      this.onPressed,
      this.text = 'Sign in with Google',
      this.darkMode = false,
      this.centerText = false,
      this.textStyle,
      this.buttonStyle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor = darkMode ? Color(0xFF4285F4) : Colors.white;
    Color textColor = darkMode ? Colors.white : Colors.black;

    Widget leading = Image.asset(
      "graphics/google-logo.png",
      package: "easy_firebase_auth",
      height: 18.0,
      width: 18.0,
    );

    return SignInButton(
      height: height,
      width: width,
      onPressed: onPressed,
      text: text,
      leading: leading,
      centerText: centerText,
      style: buttonStyle ??
          ElevatedButton.styleFrom(
            primary: buttonColor,
            onPrimary: textColor,
            textStyle: textStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
    );
  }
}
