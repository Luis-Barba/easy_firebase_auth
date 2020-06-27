import 'package:flutter/material.dart';
import 'package:easy_firebase_auth/buttons/strechable_button.dart';

/// A sign in button for twitter
class TwitterSignInButton extends StatelessWidget {
  final String text;
  final double borderRadius;
  final VoidCallback onPressed;

  TwitterSignInButton(
      {this.onPressed,
      this.text = 'Sign in with Twitter',
      // Google doesn't specify a border radius, but this looks about right.
      this.borderRadius = defaultBorderRadius,
      Key key})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StretchableButton(
      buttonColor: Color(0xFF5AB0EB),
      borderRadius: borderRadius,
      onPressed: onPressed,
      buttonPadding: 0.0,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            height: 38.0, // 40dp - 2*1dp border
            width: 38.0, // matches above
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(this.borderRadius),
            ),
            child: Center(
              child: Image(
                image: AssetImage(
                  "graphics/twitter-logo.png",
                  package: "easy_firebase_auth",
                ),
                height: 18.0,
                width: 18.0,
              ),
            ),
          ),
        ),

        SizedBox(width: 14.0 /* 24.0 - 10dp padding */),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
