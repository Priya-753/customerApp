import 'package:flutter_customer_app/nas/model/services/base_service.dart';

class TransactionService extends BaseService {
  int pageSize = 20;

  Future fetchTransactions(int customerId, int page) async {
    String url =
        "transactions/customer/$customerId?page=$page&page_size=$pageSize";
    return await BaseService().getResponse(url);
  }

  Future fetchLedgerBalance(int customerId) async {
    String url =
        "ledgerBalance?customer_id=$customerId";
    return await BaseService().getResponse(url);
  }

  Future fetchAgeingSummary(int customerId) async {
    String url =
        "ageingSummary?customer_id=$customerId";
    return await BaseService().getResponse(url);
  }
}
