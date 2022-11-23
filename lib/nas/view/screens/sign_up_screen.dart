import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/view/screens/password_reset_screen.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_customer_app/nas/model_view/auth_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  static const String id = 'sign_up_screen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _phoneNumber = 0;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    } else {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 35.0, left: 30.0, right: 30.0, bottom: 35.0),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: "8807706608",
                  prefixIcon: Icon(
                    Icons.phone,
                  ),
                ),
                keyboardType: TextInputType.phone,
                onSaved: (String? val) {
                  _phoneNumber = int.parse(val!);
                },
                validator: (String? value) {
                  return isValidPhoneNumber(value) ? null: 'Please enter a valid phone number';
                }),

            const SizedBox(
              height: 20.0,
            ),

            TextButton(
              child: Text('Receive OTP',
                  style: Theme.of(context).textTheme.bodyText1),
              onPressed: () async {
                if (validateAndSave()) {
                  await Provider.of<AuthModelView>(context, listen: false)
                      .forgotPassword(_phoneNumber);
                  ApiResponse apiResponse =
                      Provider
                          .of<AuthModelView>(context, listen: false)
                          .response;

                  switch (apiResponse.status) {
                    case Status.initial:
                    case Status.loading:
                      break;
                    case Status.completed:
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          context: context,
                          isScrollControlled: true,
                          builder: (context) =>
                              Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: PasswordResetScreen(phoneNumber: _phoneNumber),
                              ));
                      break;
                    case Status.error:
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) =>
                              FailureDialog(
                                  dialogTitle: Text(apiResponse.message!),
                                  dialogDescription:
                                  Text(apiResponse.message.toString())));
                      break;
                  }

                }
              },
            )
          ],
        ),
      ),
    );
  }
}
