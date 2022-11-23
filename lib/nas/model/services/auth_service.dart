import 'package:flutter_customer_app/nas/model/services/base_service.dart';

class AuthService extends BaseService {
  Future login(int phoneNumber, String password) async {
    String url = "login?username=$phoneNumber&password=$password";
    return await BaseService().getResponse(url, authRequired: false);
  }

  Future forgotPassword(int phoneNumber) async {
    String url = "customers/password/forgot?phone=$phoneNumber";
    return await BaseService().getResponse(url, authRequired: false, requestType: 'POST');
  }

  Future resetPassword(int phoneNumber, int otp, String password) async {
    String url = "customers/password?phone=$phoneNumber&current_password=$otp&new_password=$password";
    return await BaseService().getResponse(url, authRequired: false, requestType: 'PUT');
  }

  Future refreshToken() async {
    String url = "token/refresh";
    return await BaseService().getResponse(url, authRequired: false, refreshRequired: true);
  }

}
