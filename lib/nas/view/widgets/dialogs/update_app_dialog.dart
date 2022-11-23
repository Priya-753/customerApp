import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:store_redirect/store_redirect.dart';

class UpdateDialog extends StatelessWidget {
  final Text dialogTitle;
  final Text dialogDescription;
  final bool updateOptional;
  final bool isLoginRequired;

  const UpdateDialog(
      {Key? key, required this.dialogTitle, required this.dialogDescription, required this.updateOptional, required this.isLoginRequired})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: dialogTitle,
      content: dialogDescription,
      actions: updateOptional ? <Widget>[
        TextButton(
          onPressed: () {
            if (!isLoginRequired) {

              Navigator.pushNamed(context, AccountsScreen.id);
            } else {
              Navigator.pop(context, 'Later');
            }
          },
          child: Text('Later', style: Theme.of(context).textTheme.bodyText2),
        ),
        TextButton(
          onPressed: () {
            StoreRedirect.redirect(
              androidAppId: "com.nas.flutter_customer_app",
            );
          },
          child: Text('Update Now', style: Theme.of(context).textTheme.bodyText2),
        )
      ] : <Widget>[
        TextButton(
          onPressed: () {
            StoreRedirect.redirect(
              androidAppId: "com.nas.flutter_customer_app",
            );
          },
          child: Text('Update Now', style: Theme.of(context).textTheme.bodyText2),
        )
      ],
    );
  }
}
