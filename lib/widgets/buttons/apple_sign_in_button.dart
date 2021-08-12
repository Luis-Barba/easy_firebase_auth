import 'package:easy_firebase_auth/widgets/buttons/sign_in_button.dart';
import 'package:flutter/material.dart';

class AppleSignInButton extends StatelessWidget {
  final double? height, width;
  final String text;
  final bool darkMode;
  final VoidCallback? onPressed;
  final bool centerText;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  AppleSignInButton(
      {this.height,
      this.width,
      this.onPressed,
      this.text = 'Sign in with Apple',
      this.darkMode = false,
      this.centerText = false,
      this.textStyle,
      this.buttonStyle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor = darkMode ? Colors.black : Colors.white;
    Color textColor = darkMode ? Colors.white : Colors.black;

    Widget leading = Image.asset(
      darkMode
          ? "graphics/apple_light_icon.png"
          : "graphics/apple_dark_icon.png",
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
