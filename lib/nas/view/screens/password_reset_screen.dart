import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/model_view/auth_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/welocome_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final int phoneNumber;
  const PasswordResetScreen({Key? key, required this.phoneNumber}) : super(key: key);

  static const String id = 'password_reset_screen';
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  int _otp = 0;
  String _newPassword = "";
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final newPasswordController = TextEditingController();

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

  Future<void> fetchAllReferenceData() async {
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCustomer();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchLocations();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCompanies();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  prefixIcon: Icon(
                    Icons.perm_phone_msg_rounded,
                  ),
                ),
              onSaved: (String? val) {
                _otp = int.parse(val!);
              },
                keyboardType: TextInputType.number,
                validator: (String? value) {
              return (value == null || value.isEmpty)
                  ? 'Otp is mandatory' : null;
            }
            ),

            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(
                  Icons.password_rounded,
                ),
              ),
              controller: newPasswordController,
              onSaved: (String? val) {
                _newPassword = val!;
              },
                validator: (String? value) {
                  return (value == null || value.isEmpty)
                      ? 'Password is mandatory' : null;
                }
            ),

            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(
                  Icons.password_rounded,
                ),
              ),
                validator: (String? value) {
                  return (value ==null || value != newPasswordController.text.toString())
                  ? 'Passwords do not match' : null;
                }
            ),

            const SizedBox(
              height: 20.0,
            ),

            TextButton(
              child: Text('Reset Password', style: Theme.of(context).textTheme.bodyText2),
              onPressed: () async {
                if (validateAndSave()) {
                  await Provider.of<AuthModelView>(context, listen: false)
                      .resetPassword(widget.phoneNumber, _otp, _newPassword);
                  ApiResponse apiResponse =
                      Provider
                          .of<AuthModelView>(context, listen: false)
                          .response;

                  switch (apiResponse.status) {
                    case Status.initial:
                    case Status.loading:
                      break;
                    case Status.completed:
                      await Provider.of<AuthModelView>(context, listen: false)
                          .login(widget.phoneNumber, _newPassword);
                      ApiResponse apiResponse =
                          Provider
                              .of<AuthModelView>(context, listen: false)
                              .response;
                      await fetchAllReferenceData();

                      switch (apiResponse.status) {
                        case Status.initial:
                        case Status.loading:
                          break;
                        case Status.completed:
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                WelcomeScreen.id, (Route<dynamic> route) => false);
                          }
                          Navigator.pushReplacementNamed(context, AccountsScreen.id);
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
