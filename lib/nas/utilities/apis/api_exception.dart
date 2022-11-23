import 'package:flutter_customer_app/nas/utilities/exception.dart';

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super("Error During Communication: ", message);
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super("Invalid Request: ", message);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super("Unauthorised Request: ", message);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super("Invalid Input: ", message);
}
