import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/customer.dart';
import 'package:flutter_customer_app/nas/model/location.dart';
import 'package:flutter_customer_app/nas/model_view/reference_data_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/transaction_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/model/company.dart';
import 'package:flutter_customer_app/nas/view/screens/base_screen.dart';
import 'package:flutter_customer_app/nas/view/widgets/dialogs/failure_dialog.dart';
import 'package:flutter_customer_app/nas/view/widgets/listView/generic_list_view.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends BasePageScreen {
  const TransactionScreen({Key? key}) : super(key: key);

  static const String id = 'transaction_screen';
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends BasePageScreenState<TransactionScreen> with BaseScreen {
  List<ListViewLineItem> listViewLineItems = <ListViewLineItem>[];
  late Customer _customer;
  List<Location> _locations = [];
  List<Company> _companies = [];
  int _page = 0;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;

  @override
  void initState() {
    try {
      loadReferenceData();
    } catch (e) {
      log.severe("Error while loging in: " + e.toString());
    }
    _controller = ScrollController()..addListener(_loadMore);

    setState(() {
      screenName = "Transactions";
      selectedIndex = 1;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }


  void loadReferenceData() async {
    setState(() {
      _isFirstLoadRunning = true;
      _customer = Provider.of<ReferenceDataModelView>(context, listen: false).customer;
      _locations = Provider.of<ReferenceDataModelView>(context, listen: false).locations;
      _companies = Provider.of<ReferenceDataModelView>(context, listen: false).companies;
    });

    await fetchTransactions(context);
    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  Future<void> fetchTransactions(BuildContext context) async {
    log.info("Fetching Transactions");
    await Provider.of<TransactionModelView>(context, listen: false)
        .fetchTransactions(context, _customer.id, _page, _locations, _companies);
    ApiResponse apiResponse =
        Provider.of<TransactionModelView>(context, listen: false).response;

    switch (apiResponse.status) {
      case Status.initial:
      case Status.loading:
        break;
      case Status.completed:
        if (apiResponse.data == "Empty") {
          setState(() {
            _hasNextPage = false;
            _isLoadMoreRunning = false;
          });
        } else {
          setState(() {
            listViewLineItems.addAll(apiResponse.data);
            listViewLineItems = listViewLineItems;
          });
        }
        break;
      case Status.error:
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => FailureDialog(
                dialogTitle: Text(apiResponse.message!),
                dialogDescription: Text(apiResponse.message.toString())));
        break;
    }
  }


  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });

      _page += 1;
      await fetchTransactions(context);

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  Widget body() {
    return SafeArea(
        child: _isFirstLoadRunning ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(child: GenericListView(
                controller: _controller,
                listViewLineItems: listViewLineItems)),
            if (_isLoadMoreRunning == true)
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        )
    );
  }
}
