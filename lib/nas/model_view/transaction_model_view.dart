import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/customer.dart';
import 'package:flutter_customer_app/nas/model/services/transactions_service.dart';
import 'package:flutter_customer_app/nas/model/enums/transaction_type.dart';
import 'package:flutter_customer_app/nas/model/transaction.dart';
import 'package:flutter_customer_app/nas/model/location.dart';
import 'package:flutter_customer_app/nas/model/company.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/date_utils.dart';
import 'package:flutter_customer_app/nas/view/widgets/listView/generic_list_view.dart';
import 'package:jiffy/jiffy.dart';

class TransactionModelView extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.loading('Fetching transactions');

  final TransactionService _transactionService = TransactionService();

  final Map<int, List<ListViewLineItem>>
  _companyIdVsAgeingSummaryLineItems = {};
  final Map<int, double?>
  _companyIdVsCreditLimit = {};
  final Map<int, int?>
  _companyIdVsCreditDays = {};
  final Map<int, double> _companyIdVsLedgerBalance = {};

  ApiResponse get response {
    return _apiResponse;
  }

  Map<int, List<ListViewLineItem>> get companyIdVsAgeingSummaryLineItems {
    return _companyIdVsAgeingSummaryLineItems;
  }

  Map<int, double> get companyIdVsLedgerBalance {
    return _companyIdVsLedgerBalance;
  }

  Map<int, double?> get companyIdVsCreditLimit {
    return _companyIdVsCreditLimit;
  }

  Map<int, int?> get companyIdVsCreditDays {
    return _companyIdVsCreditDays;
  }

  Future<void> fetchTransactions(BuildContext context, int customerId, int page,
      List<Location> locations, List<Company> companies) async {
    try {
      dynamic response =
          await _transactionService.fetchTransactions(customerId, page);

      List<ListViewLineItem> transactions =
          response.map<ListViewLineItem>((tagJson) {
        Transaction transaction = Transaction.fromJson(tagJson);
        String paymentMode =
            transaction.paymentMode == null ? '' : transaction.paymentMode!;
        TransactionType transactionType =
            getTransactionType(transaction.transactionType);

        String company =
            Company.getCompany(companies, transaction.companyId)?.name ?? '';
        String location = '';
        if (transaction.locationId != null) {
          location = Location.getLocation(locations, transaction.locationId!)
                  ?.name ?? '';
        }
        String amount = transaction.amount.toString();
        String transactionTime = DateUtilities.getFormattedDate(
                DateUtilities.getJiffyFromMillis(transaction.transactionTime),
                DateUtilities.yearMonthDay) +
            " | " +
            DateUtilities.getFormattedDate(
                DateUtilities.getJiffyFromMillis(transaction.transactionTime),
                DateUtilities.hourMinute);

        return ListViewLineItem(
            icon: transactionType.isCredit
                ? const Icon(Icons.add_circle, color: Colors.green, size: 22)
                : const Icon(Icons.remove_circle, color: Colors.red, size: 22),
            leftTop: transactionType.value + " " + paymentMode,
            leftBottom: company + " " + location,
            rightTop: transactionTime,
            rightBottom: '\u{20B9} ' + amount,
            onTapCallBack: (transaction.description != null && transaction.description != "Description")
                ? () {
                    List description = transaction.description.split("\n");
                    List<ListViewLineItem> descriptionList = [];
                    for (var descriptionItem in description) {
                      descriptionList
                          .add(ListViewLineItem(leftTop: descriptionItem));
                    }
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                            child: GenericListView(
                                listViewLineItems: descriptionList)));
                  }
                : null);
      }).toList();

      if (transactions.isEmpty) {
        _apiResponse = ApiResponse.completed("Empty");
      } else {
        _apiResponse = ApiResponse.completed(transactions);
      }
    } on BadRequestException catch (e) {
      _apiResponse = ApiResponse.error("No transactions");
      log.severe("No transactions: " + e.toString());
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while fetching transactions");
      log.severe("Error while fetching transactions: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchAgeingSummary(
      Customer currentCustomer) async {
    dynamic companyIdsForAgeingSummaryAndLedgerBalanceList = companyIdsForAgeingSummaryAndLedgerBalance;
    List<ListViewLineItem> ageingSummaryLineItems = [];
    try {
      Map<String, dynamic> response = await _transactionService.fetchAgeingSummary(currentCustomer.id);

      for (int companyId in companyIdsForAgeingSummaryAndLedgerBalanceList) {

        Map<String, dynamic> responseForCompany = response[companyId.toString()];
        dynamic ageingSummaryForCompany = responseForCompany["ageing_summary"];
        int? creditDaysForCompany = responseForCompany["credit_days"];
        double? creditLimitForCompany = responseForCompany["credit_limit"];

        ageingSummaryLineItems = [];
        ageingSummaryLineItems.addAll(
            ageingSummaryForCompany.map<ListViewLineItem>((ageingSummaryItemJson) {
              String date = ageingSummaryItemJson['date'] as String;
              String pendingDays = Jiffy(date, "dd-MMM-yyyy").fromNow();

              Jiffy fromDate = DateUtilities.getJiffyFromDateTime(DateTime.now());
              Jiffy toDate = Jiffy(date, "dd-MMM-yyyy");
              double amount = (double.parse(ageingSummaryItemJson['amount'])) * -1;

              return ListViewLineItem(
                leftTop:
                '\u{20B9} ' + amount.toString(),
                leftBottom: pendingDays,
                rightTop: ageingSummaryItemJson['reference'] as String,
                rightBottom: date,
                backgroundColor: (creditDaysForCompany ?? 180) > (DateUtilities.difference(fromDate, toDate, Units.DAY))
                    ? Colors.red
                    : Colors.white,
              );
            }).toList());

        _companyIdVsAgeingSummaryLineItems[companyId] =
            ageingSummaryLineItems;
        _companyIdVsCreditDays[companyId] =
            creditDaysForCompany;
        _companyIdVsCreditLimit[companyId] =
            creditLimitForCompany;
      }
      if (ageingSummaryLineItems.isEmpty) {
        _apiResponse = ApiResponse.completed("Empty");
      } else {
        _apiResponse = ApiResponse.completed(ageingSummaryLineItems);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error("Error fetching ageing summary");
      log.severe("Error fetching ageing summary: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchLedgerBalances(
      Customer currentCustomer) async {
    dynamic companyIdsForAgeingSummaryAndLedgerBalanceList = companyIdsForAgeingSummaryAndLedgerBalance;

    try {
      Map<String, dynamic> response = await _transactionService.fetchLedgerBalance(currentCustomer.id);
      for (int companyId in companyIdsForAgeingSummaryAndLedgerBalanceList) {
        _companyIdVsLedgerBalance[companyId] = response[companyId.toString()] as double;
      }
      _apiResponse = ApiResponse.completed(_companyIdVsLedgerBalance);
    } catch (e) {
      _apiResponse = ApiResponse.error("Error fetching ledger balance");
      log.severe("Error fetching ledger balance: " + e.toString());
    }
    notifyListeners();
  }
}
