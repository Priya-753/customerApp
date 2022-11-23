import 'package:flutter/material.dart';

class FailureDialog extends StatelessWidget {
  final Text dialogTitle;
  final Text dialogDescription;

  const FailureDialog(
      {Key? key, required this.dialogTitle, required this.dialogDescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: dialogTitle,
      content: dialogDescription,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
