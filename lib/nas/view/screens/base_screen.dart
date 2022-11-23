import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/main.dart';
import 'package:flutter_customer_app/nas/model/auth_token.dart';
import 'package:flutter_customer_app/nas/model/customer.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/sqlite.dart';
import 'package:flutter_customer_app/nas/view/screens/accounts_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/admin_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/credit_discount_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/transactions_screen.dart';
import 'package:flutter_customer_app/nas/view/screens/welocome_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:provider/provider.dart';

abstract class BasePageScreen extends StatefulWidget {
  static const String id = 'base_screen';

  const BasePageScreen({Key? key}) : super(key: key);
}

abstract class BasePageScreenState<Page extends BasePageScreen> extends State<Page> {
}

mixin BaseScreen<Page extends BasePageScreen> on BasePageScreenState<Page> {

  String customerName = "";
  late String screenName;
  int selectedIndex = 0;

  @override
  void initState() {
    try {
      fetchCustomer();
      fetchLoggedInCustomer();
    } catch (e) {
      log.severe(e);
    }
    super.initState();
  }

  void _onItemTapped(int index) {
    switch(index) {
      case 0:
        Navigator.pop(context);
        Navigator.pushNamed(context, AccountsScreen.id);
        break;
      case 1:
        Navigator.pop(context);
        Navigator.pushNamed(context, TransactionScreen.id);
        break;
      case 2:
        Navigator.pop(context);
        Navigator.pushNamed(context, CreditDiscountScreen.id);
        break;
      case 3:
        Navigator.pop(context);
        Navigator.pushNamed(context, AdminScreen.id);
        break;
    }
  }

  Future<void> fetchCustomer() async {
    late Customer customer;

    try {
      customer = Provider
          .of<ReferenceDataModelView>(context, listen: false)
          .customer;
      customerName = customer.name;
    } on Exception catch (e) {
      log.severe("Error while updating customer last used time: " + e.toString());
      await Provider.of<ReferenceDataModelView>(context, listen: false)
          .fetchCustomer();

      ApiResponse apiResponse = Provider
          .of<ReferenceDataModelView>(context, listen: false)
          .response;
      switch (apiResponse.status) {
        case Status.initial:
        case Status.loading:
          break;
        case Status.completed:
          customer = apiResponse.data;
          setState(() {
            customerName = customer.name;
          });
          break;
        case Status.error:
          if (apiResponse.message == "No Internet Connection") {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                const FailureDialog(
                    dialogTitle: Text("No Internet Connection"),
                    dialogDescription:
                    Text("Please connect to internet")));
          }
          break;
      }
    }
  }

  Future<void> fetchLoggedInCustomer() async {
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchLoggedInCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(screenName),
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.account_circle, size: 30, color: Theme.of(context).colorScheme.surface),
                onSelected: (value) async {
                  if (value == 2) {
                    AuthToken currentAuthToken = await Globals.getCurrentAuthToken();
                    await SQLite.delete(SQLite.database, authTokenTableName, "id", currentAuthToken.id);
                    await SQLite.deleteAllRowsInTable(SQLite.database, ageingSummaryTableName);
                    await SQLite.deleteAllRowsInTable(SQLite.database, ageingSummaryItemTableName);
                    await SQLite.deleteAllRowsInTable(SQLite.database, ledgerBalanceTableName);
                    Globals.setCurrentAuthToken(null);
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          WelcomeScreen.id, (Route<dynamic> route) => false);
                    } else {
                      Navigator.of(context).pushReplacementNamed(WelcomeScreen.id);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    child: Text(customerName, style: Theme.of(context).textTheme.caption),
                    value: 1,
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<int>(
                    child: Text("Logout", style: Theme.of(context).textTheme.headline5),
                    value: 2,
                  )
                ]
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(child: body()),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: NasCustomerApp.darkGreen),
        child: BottomNavigationBar(
          items: getBottomNavBarItems(),
          currentIndex: selectedIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: NasCustomerApp.sandal,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed
        ),
      ),
    );
  }

  Widget body();

  List<BottomNavigationBarItem> getBottomNavBarItems() {
    Customer? customer;
    try {
      customer = Provider.of<ReferenceDataModelView>(context, listen: false).loggedInCustomer;
    } catch (e) {
      customer = Provider.of<ReferenceDataModelView>(context, listen: false).customer;
    }
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet, size: 30, color: selectedIndex == 0 ? Theme.of(context).colorScheme.onPrimary : Colors.grey),
        label: 'Accounts',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.money, size: 30, color: selectedIndex == 1 ? Theme.of(context).colorScheme.onPrimary : Colors.grey),
        label: 'Transactions',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_offer, size: 30, color: selectedIndex == 2 ? Theme.of(context).colorScheme.onPrimary : Colors.grey),
        label: 'Credit Discount',
      ),
    ];
    if (customer != null) {
      if (customer!.isSuperUser) {
        items.add(BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings, size: 30,
              color: selectedIndex == 3 ? Theme
                  .of(context)
                  .colorScheme
                  .onPrimary : Colors.grey),
          label: 'Admin',
        ));
      }
    }
    return items;
  }
}
