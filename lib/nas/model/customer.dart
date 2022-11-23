class Customer {
  final int id;
  final String name;
  final String phoneNumber;
  final String? place;
  final String? tallyLedgerName;
  final String password;
  final bool isSuperUser;

  Customer(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      this.place,
      this.tallyLedgerName,
      required this.password,
      required this.isSuperUser});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        id: json['id'] as int,
        name: json['name'] as String,
        phoneNumber: json['phone'] as String,
        place: json['place'] as String?,
        tallyLedgerName: json['tallyLedgerName'] as String?,
        password: json['password'] as String,
        isSuperUser: json['isSuperUser'] as bool
    );
  }
}
