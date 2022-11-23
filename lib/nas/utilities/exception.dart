class AppException implements Exception {
  final dynamic _prefix;
  final dynamic _message;

  AppException([this._prefix, this._message]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class NoSuchDataException extends AppException {
  NoSuchDataException([String? message])
      : super("No Such Data Exception: ", message);
}
