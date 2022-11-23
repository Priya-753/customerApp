import 'package:flutter_customer_app/nas/model/services/base_service.dart';

class MiscService extends BaseService {
  Future updateFireBaseToken(String? token) async {
    String url = "customers/firebaseToken?firebase_token=$token";
    return await BaseService().getResponse(url, requestType: 'PUT');
  }

  Future updateCustomerLastUsedTime() async {
    String url = "customers/lastUsedTime";
    return await BaseService().getResponse(url, requestType: 'PUT');
  }

  Future getVersionFromServer() async {
    String url = "version";
    return await BaseService().getResponse(url, requestType: 'GET', authRequired: false);
  }
}
