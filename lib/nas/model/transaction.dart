class Transaction {
  final int id;
  final int customerId;
  final int companyId;
  final int? locationId;
  final String transactionType;
  final String description;
  final int transactionTime;
  final double amount;
  final String? paymentMode;

  Transaction(
      {required this.id,
      required this.customerId,
      required this.companyId,
      required this.locationId,
      required this.description,
      required this.transactionType,
      required this.transactionTime,
      required this.amount,
      this.paymentMode});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['id'] as int,
        customerId: json['customer'] as int,
        companyId: json['company'] as int,
        locationId: json['location'] as int?,
        description: json['description'] as String,
        transactionType: json['transactionType'] as String,
        transactionTime: json['transactionTime'] as int,
        amount: json['amount'] as double,
        paymentMode: json['paymentMode'] as String?);
  }
}
