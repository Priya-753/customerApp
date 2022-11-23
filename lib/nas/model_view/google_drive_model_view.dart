import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/services/google_drive_service.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';

class DriveModelView extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.loading('Fetching documents');

  late final Uint8List _creditDiscountStructureBytes;

  ApiResponse get response {
    return _apiResponse;
  }

  Uint8List get creditDiscountStructureBytes {
    return _creditDiscountStructureBytes;
  }

  Future<void> fetchCreditDiscountStructure() async {
    try {
      dynamic response =
          await DriveService.getDocumentAsPdf(creditDiscountDocId);
      _creditDiscountStructureBytes = response;

      _apiResponse = ApiResponse.completed(response);
    } on FetchDataException {
      _apiResponse = ApiResponse.error("Please connect to the internet");
      log.severe("Please connect to the internet");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error reaching server.");
      log.severe("Error fetching credit discount file." + e.toString());
    }
    notifyListeners();
  }
}
