enum TransactionType {
  purchase,
  paymentReceipt,
  salesReturn,
  creditNote,
  creditDiscount,
  chequeBounce,
  uncategorized
}

extension TransactionTypeExtension on TransactionType {
  bool get isCredit {
    switch (this) {
      case TransactionType.purchase:
        return false;
      case TransactionType.paymentReceipt:
        return true;
      case TransactionType.salesReturn:
        return true;
      case TransactionType.creditNote:
        return true;
      case TransactionType.creditDiscount:
        return true;
      case TransactionType.chequeBounce:
        return false;
      case TransactionType.uncategorized:
        return true;
    }
  }

  String get value {
    switch (this) {
      case TransactionType.purchase:
        return "PURCHASE";
      case TransactionType.paymentReceipt:
        return "PAYMENT RECEIPT";
      case TransactionType.salesReturn:
        return "SALES RETURN";
      case TransactionType.creditNote:
        return "CREDIT NOTE";
      case TransactionType.creditDiscount:
        return "CREDIT DISCOUNT";
      case TransactionType.chequeBounce:
        return "CHEQUE BOUNCE";
      case TransactionType.uncategorized:
        return "UN CATEGORIZED";
    }
  }
}

TransactionType getTransactionType(String transactionType) {
  switch (transactionType) {
    case "SALES":
      return TransactionType.purchase;
    case "PAYMENT_RECEIPT":
      return TransactionType.paymentReceipt;
    case "SALES_RETURN":
      return TransactionType.salesReturn;
    case "CREDIT_NOTE":
      return TransactionType.creditNote;
    case "CREDIT_DISCOUNT":
      return TransactionType.creditDiscount;
    case "CHEQUE_BOUNCE":
      return TransactionType.chequeBounce;
    default:
      return TransactionType.uncategorized;
  }
}