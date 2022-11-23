import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const RoundedButton({@required this.text, @required this.onPressed});

  final Text? text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialButton(onPressed: onPressed, child: text),
    );
  }
}
