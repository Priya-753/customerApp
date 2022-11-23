import 'dart:convert';
import 'dart:io';

import 'package:flutter_customer_app/nas/model/auth_token.dart';
import 'package:flutter_customer_app/nas/model/services/google_drive_service.dart';
import 'package:flutter_customer_app/nas/model_view/auth_model_view.dart';
import 'package:flutter_customer_app/nas/model_view/misc_model_view.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/date_utils.dart';
import 'package:flutter_customer_app/nas/utilities/exception.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class BaseService {

  Future getResponse(String url,
      {authRequired = true, requestType = 'GET', refreshRequired = false, responseFormat = 'json'}) async {
    String baseUrl = "http://34.105.93.238:5000/api/v1/";
    var request = http.Request(requestType, Uri.parse(baseUrl + url));
    try {
      AuthToken authToken = await Globals.getCurrentAuthToken();

      if (refreshRequired) {
        var headers = {'Authorization': 'Bearer ${authToken.refreshToken}'};
        request.headers.addAll(headers);
      } else if (authRequired) {
        Jiffy fromDate = DateUtilities.getJiffyFromDateTime(DateTime.now());
        Jiffy toDate = DateUtilities.getJiffyFromMillis(authToken.createdTime);

        if (DateUtilities.difference(fromDate, toDate, Units.MINUTE) > 14) {
          log.info("Token Refresh Required at " + DateUtilities.getFormattedDate(fromDate, DateUtilities.hourMinute) + ".Last token refresh was at " + DateUtilities.getFormattedDate(toDate, DateUtilities.hourMinute));
          await AuthModelView().refreshToken();
          authToken = await Globals.getCurrentAuthToken();

          Jiffy? lastUsedTime = Globals.lastUsedTime;
          if (lastUsedTime == null || DateUtilities.difference(fromDate, lastUsedTime, Units.HOUR) > 5) {
            await MiscModelView().updateCustomerLastUsedTime();
          }
        }

        var headers = {'Authorization': 'Bearer ${authToken.accessToken}'};
        request.headers.addAll(headers);
      }
    } on NoSuchDataException catch (e) {
      log.severe(e);
    }

    dynamic formattedResponse;
    try {
      log.info("URL " + request.url.toString());
      log.info("HEADERS " + request.headers.toString());
      final response = await request.send();
      formattedResponse = returnResponse(response, responseFormat);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return formattedResponse;
  }

  Future getDriveUtilsResponse(String url, {requestType = 'GET', refreshRequired = false, responseFormat = 'json'}) async {
    var request = http.Request(requestType, Uri.parse(url));
    try {
      String driveAccessToken = Globals.driveAccessToken;
      Jiffy? driveAccessTokenTime = Globals.driveAccessTokenTime;
      Jiffy currentTime = DateUtilities.getJiffyFromDateTime(DateTime.now());

      if (refreshRequired == false) {
        if (driveAccessTokenTime == null
              || DateUtilities.difference(currentTime, driveAccessTokenTime, Units.MILLISECOND) > 2000000)
      {
        dynamic response = await DriveService.getAccessTokenUsingRefreshToken();
        driveAccessToken = response["access_token"].toString();
        Globals.setDriveAccessToken(driveAccessToken);
      }
      var headers = {'Authorization': 'Bearer $driveAccessToken'};
      request.headers.addAll(headers);
    }

    } on Exception catch (e) {
      log.severe(e);
    }

    dynamic responseJson;
    try {
      log.info("Google Drive Service URL " + request.url.toString());
      log.info("Google Drive Service HEADERS " + request.headers.toString());
      final response = await request.send();
      responseJson = returnResponse(response, responseFormat);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  dynamic returnResponse(http.StreamedResponse response, responseFormat) async {
    switch (response.statusCode) {
      case 200:
        if (responseFormat == 'json') {
          dynamic formattedResponse =
          jsonDecode(await response.stream.bytesToString());
          return formattedResponse;
        } else {
          dynamic formattedResponse = response.stream.toBytes();
          return formattedResponse;
        }
      case 400:
        throw BadRequestException(response.stream.bytesToString());
      case 401:
      case 403:
        throw UnauthorisedException(response.stream.bytesToString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while communication with server with status code : ${response.statusCode}');
    }
  }
}
