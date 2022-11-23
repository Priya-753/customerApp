import 'package:flutter_customer_app/nas/model/services/base_service.dart';

class ReferenceDataService extends BaseService {
  int pageSize = 20;

  Future fetchCustomer() async {
    String url = "customers/current";
    return await BaseService().getResponse(url);
  }

  Future fetchCustomerFromPhoneNumber(int phoneNumber) async {
    String url = "customers/phone/$phoneNumber";
    return await BaseService().getResponse(url);
  }

  Future fetchLocations(int page) async {
    String url = "locations?page=$page&page_size=$pageSize";
    return await BaseService().getResponse(url);
  }

  Future fetchCompanies(int page) async {
    String url = "companies?page=$page&page_size=$pageSize";
    return await BaseService().getResponse(url);
  }

  Future fetchCustomerInTallyForCustomer(int customerId) async {
    String url = "customerInTally/$customerId";
    return await BaseService().getResponse(url);
  }
}
