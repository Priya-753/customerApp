class CustomerInTally {
  final int id;
  final int customerId;
  final int companyId;
  final String tallyLedgerName;
  final double creditLimit;
  final int creditDays;

  CustomerInTally(
      {required this.id,
      required this.customerId,
      required this.companyId,
      required this.tallyLedgerName,
      required this.creditLimit,
      required this.creditDays});

  factory CustomerInTally.fromJson(Map<String, dynamic> json) {
    return CustomerInTally(
      id: json['id'] as int,
      customerId: json['customer'] as int,
      companyId: json['company'] as int,
      tallyLedgerName: json['tallyLedgerName'] as String,
      creditLimit: json['creditLimit'] as double,
      creditDays: json['creditDays'] as int,
    );
  }

  static CustomerInTally? getCustomerInTallyForCompany(List<CustomerInTally> customerInTallyList, int companyId) {
    CustomerInTally? customerInTally;
    List.generate(customerInTallyList.length, (i) {
      if (customerInTallyList[i].companyId == companyId) {
        customerInTally = customerInTallyList[i];
      }
    });
    return customerInTally;
  }
}
