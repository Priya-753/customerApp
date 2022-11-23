import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/model_view/auth_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/sign_up_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/welocome_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _phoneNumber = 0;
  String _password = "";

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

  Future<void> fetchAllReferenceData() async {
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCustomer();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchLocations();
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCompanies();
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

            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(
                  Icons.password_rounded,
                ),
              ),
              onSaved: (String? val) {
                _password = val!;
              },validator: (String? value) {
              return (value == null || value.isEmpty)
                  ? 'Password is mandatory' : null;
            }
            ),

            const SizedBox(
              height: 20.0,
            ),

            TextButton(
              child: Text('Log In', style: Theme.of(context).textTheme.bodyText2),
              onPressed: () async {
                if (validateAndSave()) {
                  await Provider.of<AuthModelView>(context, listen: false)
                      .login(_phoneNumber, _password);
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
                }
              },
            ),

            const SizedBox(
              height: 20.0,
            ),

            OutlinedButton(
                child: Text("Forgot Password",
                style: Theme.of(context).textTheme.overline),
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: const SignUpScreen(),
                      )
                  );
                }
              )
          ],
        ),
      ),
    );
  }
}
