import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/sqlite.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/base_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/listView/generic_list_view.dart';
import 'package:provider/provider.dart';

import '../widgets/dialogs/failure_dialog.dart';

class AdminScreen extends BasePageScreen {
  const AdminScreen({Key? key}) : super(key: key);

  static const String id = 'admin_screen';
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends BasePageScreenState<AdminScreen>
    with BaseScreen {
  int _phoneNumber = 0;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      screenName = "Admin";
      selectedIndex = 3;
    });
  }

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
  Widget body() {
    ListViewLineItem viewCustomerTransactions = ListViewLineItem(
        icon: const Icon(Icons.person_search),
        leftTop: "View Customer Transactions",
        onTapCallBack: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => Dialog(
                      child: Container(
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
                                labelText: 'Phone Number of Customer',
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
                                return isValidPhoneNumber(value)
                                    ? null
                                    : 'Please enter a valid phone number';
                              }),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextButton(
                            child: Text('Submit',
                                style: Theme.of(context).textTheme.bodyText2),
                            onPressed: () async {
                              if (validateAndSave()) {
                                await Provider.of<ReferenceDataModelView>(
                                        context,
                                        listen: false)
                                    .fetchCustomerFromPhoneNumber(_phoneNumber);
                                ApiResponse apiResponse =
                                    Provider.of<ReferenceDataModelView>(context,
                                            listen: false)
                                        .response;

                                switch (apiResponse.status) {
                                  case Status.initial:
                                  case Status.loading:
                                    break;
                                  case Status.completed:
                                    await SQLite.deleteAllRowsInTable(SQLite.database, ageingSummaryTableName);
                                    await SQLite.deleteAllRowsInTable(SQLite.database, ageingSummaryItemTableName);
                                    await SQLite.deleteAllRowsInTable(SQLite.database, ledgerBalanceTableName);
                                    Navigator.pushReplacementNamed(
                                        context, AccountsScreen.id);
                                    break;
                                  case Status.error:
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            FailureDialog(
                                                dialogTitle:
                                                    Text(apiResponse.message!),
                                                dialogDescription: Text(
                                                    apiResponse.message
                                                        .toString())));
                                    break;
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )));
        });

    List<ListViewLineItem> adminFunctions = [];
    adminFunctions.add(viewCustomerTransactions);

    return Container(
      padding: const EdgeInsets.only(
          top: 35.0, left: 30.0, right: 30.0, bottom: 35.0),
      child: GenericListView(listViewLineItems: adminFunctions),
    );
  }
}
