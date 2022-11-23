import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/company.dart';
import 'package:flutter_customer_app/nas/model/customer.dart';
import 'package:flutter_customer_app/nas/model_view/misc_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/transaction_model_view.dart';
import 'package:flutter_customer_app/nas/view/screens/base_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/gridView/card_grid_view.dart';
import 'package:flutter_customer_app/nas/view/widgets/listView/generic_list_view.dart';
import 'package:provider/provider.dart';

class AccountsScreen extends BasePageScreen {
  const AccountsScreen({Key? key}) : super(key: key);

  static const String id = 'accounts_screen';
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends BasePageScreenState<AccountsScreen>
    with BaseScreen {
  late Customer _customer;
  List<Company> _companies = [];
  Map<int, double> _companyIdVsLedgerBalance = {};
  Map<int, double?> _companyIdVsCreditLimit = {};
  Map<int, int?> _companyIdVsCreditDays = {};
  Map<int, List<ListViewLineItem>> _companyIdVsAgeingSummaryLineItems =
      {};
  bool _isBalanceFetchComplete = false;
  List<GridViewItem> _gridViewItems = <GridViewItem>[];
  List<ListViewLineItem> _ageingSummary = <ListViewLineItem>[];
  bool _isAgeingSummaryFetchComplete = false;
  String currentCompanyAgeingSummary = "National Agro Services";

  @override
  void initState() {
    super.initState();
    try {
      updateFirebaseTokenOnLogin();
    } catch (e) {
      log.severe(e);
    }

    setState(() {
      screenName = "Accounts";
      selectedIndex = 0;
    });
    fetchReferenceData();
  }

  @override
  Future<void> fetchCustomer() async {
    await Provider.of<ReferenceDataModelView>(context, listen: false)
        .fetchCustomer();
    Customer customer =
        Provider.of<ReferenceDataModelView>(context, listen: false).customer;
    customerName = customer.name;
    setState(() {
      _customer = customer;
    });
  }

  Future<void> fetchReferenceData() async {
    await fetchCustomer();
    List<Company> companies =
        Provider.of<ReferenceDataModelView>(context, listen: false).companies;

    setState(() {
      _companies = companies;
    });

    await fetchAgeingSummary();
    await fetchBalance();
  }

  void updateFirebaseTokenOnLogin() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await Provider.of<MiscModelView>(context, listen: false)
        .updateFirebaseToken(token);
  }

  Future<void> fetchAgeingSummary() async {
    log.info("Fetching Ageing Summary");

    await Provider.of<TransactionModelView>(context, listen: false)
        .fetchAgeingSummary(_customer);

    Map<int, List<ListViewLineItem>> companyIdVsAgeingSummaryLineItems =
        Provider.of<TransactionModelView>(context, listen: false)
            .companyIdVsAgeingSummaryLineItems;

    setState(() {
      _ageingSummary =
          companyIdVsAgeingSummaryLineItems[nasCompanyId] ?? [];
      _companyIdVsAgeingSummaryLineItems =
          companyIdVsAgeingSummaryLineItems;
      _isAgeingSummaryFetchComplete = true;
    });
  }

  Future<void> fetchBalance() async {
    log.info("Fetching Balance");

    setState(() {
      _isBalanceFetchComplete = false;
    });

    await Provider.of<TransactionModelView>(context, listen: false)
        .fetchLedgerBalances(_customer);

    Map<int, double> companyIdVsLedgerBalance =
        Provider.of<TransactionModelView>(context, listen: false)
            .companyIdVsLedgerBalance;
    Map<int, double?> companyIdVsCreditLimit =
        Provider.of<TransactionModelView>(context, listen: false)
            .companyIdVsCreditLimit;
    Map<int, int?> companyIdVsCreditDays =
        Provider.of<TransactionModelView>(context, listen: false)
            .companyIdVsCreditDays;

    setState(() {
      _companyIdVsLedgerBalance = companyIdVsLedgerBalance;
      _companyIdVsCreditLimit = companyIdVsCreditLimit;
      _companyIdVsCreditDays = companyIdVsCreditDays;
    });

    prepareBalanceAndAgeingDisplay();
  }

  void prepareBalanceAndAgeingDisplay() {
    var companyIdVsAccounts = {};
    for (Company company in _companies) {
      if (company.id == 11 || company.id == 12 || company.id == 13) {
        if (_companyIdVsLedgerBalance[company.id] == 0 || _companyIdVsLedgerBalance[company.id] == null) {
          continue;
        }
        companyIdVsAccounts[company.id] = {
          'companyName': company.name,
          'ledgerBalance': _companyIdVsLedgerBalance[company.id]! * -1 ,
          'ageingSummary': _companyIdVsAgeingSummaryLineItems[company.id],
          'creditLimit': _companyIdVsCreditLimit[company.id],
          'creditDays': _companyIdVsCreditDays[company.id],
        };
      }
    }

    List<GridViewItem> gridViewItems = [];
    companyIdVsAccounts.forEach((companyId, accountDetail) {
      gridViewItems.add(
          GridViewItem(
              title: 'Balance: \u{20B9} ' + (companyIdVsAccounts[companyId]['ledgerBalance'].toString()),
              text:
              companyIdVsAccounts[companyId]['companyName'] + "\n Limit: " + companyIdVsAccounts[companyId]['creditLimit'].toString(),
              color: companyIdVsAccounts[companyId]['ledgerBalance'] >
                  companyIdVsAccounts[companyId]['creditLimit']
                  ? Colors.red
                  : Colors.grey,
              onTapCallBack: () {
                setState(() {
                  _ageingSummary = companyIdVsAccounts[companyId]['ageingSummary'];
                  currentCompanyAgeingSummary = companyIdVsAccounts[companyId]['companyName'];
                });
              })
      );
    });

    setState(() {
      _gridViewItems = gridViewItems;
      _isBalanceFetchComplete = true;
    });
  }

  @override
  Widget body() {
    return SafeArea(
        child: Column(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: _isBalanceFetchComplete
                ? RefreshIndicator(
                    color: Theme.of(context).colorScheme.background,
                    child: CardGridView(gridViewItems: _gridViewItems),
                    onRefresh: () {
                      return fetchBalance();
                    },
                  )
                : const Center(child: CircularProgressIndicator())),
        RichText(
            text: TextSpan(children: [
          const WidgetSpan(
            child: Icon(Icons.history_edu),
          ),
          TextSpan(
            text: 'Ageing Summary: ' + currentCompanyAgeingSummary,
            style: Theme.of(context).textTheme.headline6,
          )
        ])),
        Expanded(
            child: SizedBox(
                height: 3 * MediaQuery.of(context).size.height / 4,
                child: _isAgeingSummaryFetchComplete
                    ? RefreshIndicator(
                        color: Theme.of(context).colorScheme.background,
                        child:
                            GenericListView(listViewLineItems: _ageingSummary),
                        onRefresh: () {
                          return fetchAgeingSummary();
                        },
                      )
                    : const Center(child: CircularProgressIndicator())))
      ],
    ));
  }
}
