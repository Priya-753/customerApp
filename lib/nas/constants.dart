import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/model/auth_token.dart';
import 'package:flutter_customer_app/nas/utilities/date_utils.dart';
import 'package:flutter_customer_app/nas/utilities/sqlite.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logging/logging.dart';

import 'package:flutter_customer_app/main.dart';

class Globals {
  static AuthToken? currentAuthToken;
  static String driveAccessToken = "";
  static Jiffy? driveAccessTokenTime;
  static Jiffy? lastUsedTime;

  static setCurrentAuthToken(AuthToken? authToken) {
    log.info("Auth token updated to " + authToken.toString());
    currentAuthToken = authToken;
  }

  static getCurrentAuthToken() async {
    if (Globals.currentAuthToken == null) {
      List authTokenJson = await SQLite.get(SQLite.database, authTokenTableName, 'id', 1);
      AuthToken currentAuthToken =
          AuthToken.fromJson(authTokenJson[0]);
      Globals.setCurrentAuthToken(currentAuthToken);
    }
    return currentAuthToken;
  }

  static setDriveAccessToken(String driveAccessTkn) {
    driveAccessToken = driveAccessTkn;
    driveAccessTokenTime = DateUtilities.getJiffyFromDateTime(DateTime.now());
  }

  static setLastUsedTime(Jiffy lastUsedTimeJiffy) {
    lastUsedTime = lastUsedTimeJiffy;
  }
}

const authTokenTableName = "authToken";
const ageingSummaryTableName = "ageingSummary";
const ageingSummaryItemTableName = "ageingSummaryItem";
const ledgerBalanceTableName = "ledgerBalance";
const baseUrlDocId = "1P5gGx4tEXJgndKKthrZnuVGHqAV-9YgkKFlA5uhBtxM";
const creditDiscountDocId = "1RYs-z8nIWeP2lJFcQY_QPqME84efh-zSTlJtyjQRd9I";
const creditDiscountFilePath = "/storage/emulated/0/Download/CreditDiscountStructure.pdf";
const nasCompanyId = 11;
const vtCompanyId = 12;
const smaCompanyId = 13;

dynamic companyIdsForAgeingSummaryAndLedgerBalance = [
  nasCompanyId,
  vtCompanyId,
  smaCompanyId
];

bool isValidPhoneNumber(String? value) {
  String pattern = '^(?:[+0]9)?[0-9]{10}';
  RegExp regex = RegExp(pattern);
  if (value != null && regex.hasMatch(value)) {
    return true;
  } else {
    return false;
  }
}

final log = Logger('CUSTOMER APP');

ThemeData themeData = ThemeData(
    colorScheme: const ColorScheme(
        primary: NasCustomerApp.darkGreen,
        secondary: NasCustomerApp.darkBlue,
        surface: NasCustomerApp.sandal,
        background: Colors.grey,
        error: NasCustomerApp.red,
        onPrimary: NasCustomerApp.sandal,
        onSecondary: NasCustomerApp.sandal,
        onSurface: NasCustomerApp.darkGreen,
        onBackground: NasCustomerApp.darkGreen,
        onError: NasCustomerApp.sandal,
        brightness: Brightness.light),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            primary: NasCustomerApp.sandal,
            backgroundColor: NasCustomerApp.darkGreen,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            minimumSize: const Size(150.0, 10.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0))),
    dividerTheme: const DividerThemeData(
        color: Colors.grey, indent: 10.0, endIndent: 10.0),
    errorColor: NasCustomerApp.red,
    focusColor: NasCustomerApp.darkGreen,
    hintColor: NasCustomerApp.darkGreen,
    canvasColor: NasCustomerApp.sandal,
    cardColor: NasCustomerApp.sandal,
    iconTheme: const IconThemeData(color: NasCustomerApp.darkGreen),
    scaffoldBackgroundColor: Colors.grey,
    textTheme: const TextTheme(
            headline3:
                TextStyle(fontSize: 28.0, color: NasCustomerApp.darkGreen),
            headline4:
                TextStyle(fontSize: 34.0, color: NasCustomerApp.darkGreen),
            headline5: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline6: TextStyle(
                fontSize: 16.0,
                color: NasCustomerApp.darkBlue,
                fontWeight: FontWeight.bold),
            bodyText1: TextStyle(fontSize: 28.0, color: NasCustomerApp.sandal),
            bodyText2: TextStyle(fontSize: 24.0, color: NasCustomerApp.sandal),
            caption: TextStyle(fontSize: 14.0, color: Colors.black54),
            overline: TextStyle(
                fontSize: 12.0,
                color: NasCustomerApp.darkBlue,
                decoration: TextDecoration.underline))
        .apply(fontFamily: 'Times New Roman'));
