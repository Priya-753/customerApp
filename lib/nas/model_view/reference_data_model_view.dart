import 'package:flutter/cupertino.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/model/company.dart';
import 'package:flutter_customer_app/nas/model/customer.dart';
import 'package:flutter_customer_app/nas/model/customer_in_tally.dart';
import 'package:flutter_customer_app/nas/model/location.dart';
import 'package:flutter_customer_app/nas/model/services/reference_data_service.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_exception.dart';
import 'package:flutter_customer_app/nas/utilities/apis/api_response.dart';

class ReferenceDataModelView extends ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.loading('Fetching reference data');
  final List<Location> _locations = [];
  final List<Company> _companies = [];
  List<CustomerInTally> _customerInTallyList = [];
  late Customer _customer;
  late Customer _loggedInCustomer;

  final ReferenceDataService _referenceDataService = ReferenceDataService();

  ApiResponse get response {
    return _apiResponse;
  }

  Customer get customer {
    return _customer;
  }

  Customer get loggedInCustomer {
    return _loggedInCustomer;
  }

  List<Location> get locations {
    return _locations;
  }

  List<Company> get companies {
    return _companies;
  }

  List<CustomerInTally> get customerInTally {
    return _customerInTallyList;
  }

  Future<void> fetchCustomer() async {
    log.info("Fetching Customer");
    try {
      dynamic response = await _referenceDataService.fetchCustomer();
      Customer customer = Customer.fromJson(response);
      _apiResponse = ApiResponse.completed(customer);
      _customer = customer;
    } on BadRequestException catch (e) {
      _apiResponse = ApiResponse.error("No such customer.");
      log.severe("No such customer: " + e.toString());
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while fetching customer");
      log.severe("Error while fetching customer: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchCustomerFromPhoneNumber(int phoneNumber) async {
    log.info("Fetching Customer From Phone Number");
    try {
      dynamic response = await _referenceDataService.fetchCustomerFromPhoneNumber(phoneNumber);
      Customer customer = Customer.fromJson(response);
      _apiResponse = ApiResponse.completed(customer);
      _customer = customer;
    } on BadRequestException catch (e) {
      _apiResponse = ApiResponse.error("No such customer.");
      log.severe("No such customer: " + e.toString());
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while fetching customer from phone number");
      log.severe("Error while fetching customer from phone number " + e.toString());
    }
    notifyListeners();
  }


  Future<void> fetchLoggedInCustomer() async {
    log.info("Fetching Logged In Customer");
    try {
      dynamic response = await _referenceDataService.fetchCustomer();
      Customer customer = Customer.fromJson(response);
      _apiResponse = ApiResponse.completed(customer);
      _loggedInCustomer = customer;
    } on BadRequestException catch (e) {
      _apiResponse = ApiResponse.error("No such customer.");
      log.severe("No such customer: " + e.toString());
    } on FetchDataException {
      _apiResponse = ApiResponse.error("No Internet Connection");
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while fetching customer");
      log.severe("Error while fetching customer: " + e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchLocations() async {
    int page = 0;
    bool fetchComplete = false;

    while(!fetchComplete) {
      log.info("Fetching Locations in page" + page.toString());
      try {
        dynamic response = await _referenceDataService.fetchLocations(page);
        if (response["content"].toString() != "[]") {
          _locations.addAll(response["content"]
              .map<Location>((tagJson) => Location.fromJson(tagJson))
              .toList());
          page++;
        } else {
          fetchComplete = true;
        }
      } catch (e) {
        fetchComplete = true;
        _apiResponse = ApiResponse.error("Error while fetching locations");
        log.severe("Error while fetching locations: " + e.toString());
      }
    }
    _apiResponse = ApiResponse.completed(_locations);
    notifyListeners();
  }

  Future<void> fetchCompanies() async {
    int page = 0;
    bool fetchComplete = false;

    while(!fetchComplete) {
      log.info("Fetching Companies in page" + page.toString());
      try {
        dynamic response = await _referenceDataService.fetchCompanies(page);
        if (response.toString() != "[]") {
          _companies.addAll(response
              .map<Company>((tagJson) => Company.fromJson(tagJson))
              .toList());
          page++;
        } else {
          fetchComplete = true;
        }
      } catch (e) {
        fetchComplete = true;
        _apiResponse = ApiResponse.error("Error while fetching companies");
        log.severe("Error while fetching companies: " + e.toString());
      }
    }
    _apiResponse = ApiResponse.completed(_companies);
    notifyListeners();
  }

  Future<void> fetchCustomerInTallyForCustomer(int customerId) async {
    _customerInTallyList = [];
    try {
      dynamic response = await _referenceDataService.fetchCustomerInTallyForCustomer(customerId);
      _customerInTallyList.addAll(response
          .map<CustomerInTally>((tagJson) => CustomerInTally.fromJson(tagJson))
          .toList());
      _apiResponse = ApiResponse.completed(_customerInTallyList);
    } on BadRequestException catch (e) {
      _apiResponse = ApiResponse.error("No customer in tally items");
      log.severe("No customer in tally items: " + e.toString());
    } catch (e) {
      _apiResponse = ApiResponse.error("Error while fetching customer in tally items");
      log.severe("Error while fetching customer in tally items: " + e.toString());
    }
    notifyListeners();
  }
}
