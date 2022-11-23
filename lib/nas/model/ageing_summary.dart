class AgeingSummary {
  final int? id;
  final String documentId;
  final int createdTime;
  final int lastUpdatedTime;

  AgeingSummary({
    this.id,
    required this.documentId,
    required this.createdTime,
    required this.lastUpdatedTime
  });

  factory AgeingSummary.fromJson(Map<String, dynamic> json) {
    return AgeingSummary(
        id: json['id'],
        documentId: json['document_id'] as String,
        createdTime: json['created_time'] ?? DateTime.now().millisecondsSinceEpoch,
        lastUpdatedTime: json['last_updated_time'] ?? DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'created_time': createdTime,
      'last_updated_time': lastUpdatedTime
    };
  }
}

class AgeingSummaryItem {
  final int? id;
  final String reference;
  final String date;
  final double amount;
  final int ageingSummaryId;

  AgeingSummaryItem({
    this.id,
    required this.reference,
    required this.date,
    required this.amount,
    required this.ageingSummaryId
  });

  factory AgeingSummaryItem.fromJson(Map<String, dynamic> json) {
    return AgeingSummaryItem(
        id: json['id'],
        reference: json['reference'] as String,
        date: json['date'],
        amount: json['amount'],
        ageingSummaryId: json['ageing_summary_id']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'date': date,
      'amount': amount,
      'ageing_summary_id': ageingSummaryId
    };
  }
}
