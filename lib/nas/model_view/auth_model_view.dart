import 'package:flutter/cupertino.dart';
import 'package:flutter_customer_app/nas/model/auth_token.dart';
import 'package:flutter_customer_app/nas/model/services/auth_service.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';
import 'package:flutter_customer_app/nas/utilities/sqlite.dart';
import 'package:flutter_customer_app/nas/constants.dart';

class AuthModelView extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.loading('Logging in...');

  final AuthService _authService = AuthService();

  ApiResponse get response {
    return _apiResponse;
  }

  Future<void> login(int phoneNumber, String password) async {
    try {
      dynamic response = await _authService.login(phoneNumber, password);
      AuthToken authToken = AuthToken.fromJson(response);
      SQLite.insert(SQLite.database, authTokenTableName, authToken);
      _apiResponse = ApiResponse.completed(authToken);
    } on UnauthorisedException catch (e) {
      _apiResponse =
          ApiResponse.error("The credentials given are incorrect.");
      log.severe("The credentials given are incorrect." + e.toString());
    }  on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while loging in.");
      log.severe("Error while loging in: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> refreshToken() async {
    try {
      dynamic response = await _authService.refreshToken();
      AuthToken oldAuthToken = await Globals.getCurrentAuthToken();
      response["id"] = oldAuthToken.id;
      AuthToken authToken = AuthToken.fromJson(response);

      SQLite.update(SQLite.database, authTokenTableName, authToken, "id", oldAuthToken.id);
      List authTokenJson = await SQLite.get(SQLite.database, authTokenTableName, 'id', 1);
      authToken = AuthToken.fromJson(authTokenJson[0]);
      Globals.setCurrentAuthToken(authToken);
      _apiResponse = ApiResponse.completed(authToken);
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while refreshing token");
      log.severe("Error while refreshing token: " + e.toString());
    }
  }

  Future<void> forgotPassword(int phoneNumber) async {
    try {
      dynamic response = await _authService.forgotPassword(phoneNumber);
      _apiResponse = ApiResponse.completed(response);
    } on UnauthorisedException catch (e) {
      _apiResponse =
          ApiResponse.error("The phone number is not registered with us.");
      log.severe("The phone number is not registered with us." + e.toString());
    }   on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error in forgot password");
      log.severe("Error in forgot password: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> resetPassword(int phoneNumber, int otp, String password) async {
    try {
      dynamic response = await _authService.resetPassword(phoneNumber, otp, password);
      _apiResponse = ApiResponse.completed(response);
    } on BadRequestException catch (e) {
      _apiResponse =
          ApiResponse.error("The otp entered is incorrect.");
      log.severe("The otp entered is incorrect." + e.toString());
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while resetting password");
      log.severe("Error while resetting password: " + e.toString());
    }
    notifyListeners();
  }
}
