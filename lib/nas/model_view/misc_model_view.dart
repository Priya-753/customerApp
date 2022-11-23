import 'package:flutter/cupertino.dart';
import 'package:flutter_customer_app/nas/model/services/misc_service.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/date_utils.dart';
import 'package:flutter_customer_app/nas/constants.dart';

class MiscModelView extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.loading('Loading...');

  final MiscService _miscService = MiscService();

  ApiResponse get response {
    return _apiResponse;
  }

  Future<void> updateCustomerLastUsedTime() async {
    try {
      dynamic response = await _miscService.updateCustomerLastUsedTime();
      Globals.setLastUsedTime(DateUtilities.getJiffyFromDateTime(DateTime.now()));
      _apiResponse = ApiResponse.completed(response);
    } catch (e) {
      _apiResponse = ApiResponse.error("Error");
      log.severe("Error while updating customer last used time: " + e.toString());
    }
  }

  Future<void> updateFirebaseToken(String? token) async {
    try {
      dynamic response = await _miscService.updateFireBaseToken(token);
      _apiResponse = ApiResponse.completed(response);
    } catch (e) {
      _apiResponse = ApiResponse.error("Error");
      log.severe("Error while updating firebase token: " + e.toString());
    }
  }

  Future<void> getVersionFromServer() async {
    try {
      dynamic response = await _miscService.getVersionFromServer();
      _apiResponse = ApiResponse.completed(response);
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error");
      log.severe("Error while updating customer last used time: " + e.toString());
    }
    notifyListeners();
  }
}
