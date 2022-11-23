class LedgerBalance {
  final int? id;
  final String documentId;
  final double balance;
  final int createdTime;
  final int lastUpdatedTime;

  LedgerBalance({
    this.id,
    required this.documentId,
    required this.balance,
    required this.createdTime,
    required this.lastUpdatedTime
  });

  factory LedgerBalance.fromJson(Map<String, dynamic> json) {
    return LedgerBalance(
        id: json['id'],
        documentId: json['document_id'],
        balance: json['balance'],
        createdTime: json['created_time'] ?? DateTime.now().millisecondsSinceEpoch,
        lastUpdatedTime: json['last_updated_time'] ?? DateTime.now().millisecondsSinceEpoch
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'balance': balance,
      'created_time': createdTime,
      'last_updated_time': lastUpdatedTime
    };
  }
}