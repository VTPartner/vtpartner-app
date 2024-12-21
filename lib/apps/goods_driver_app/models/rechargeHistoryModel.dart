class RechargeHistoryModel {
  final int historyID;
  final int rechargeID;
  final double amount;
  final double points;
  final String rechargeDate;
  final String validTillDate;
  final String paymentID;
  final double lastRechargeNegativePoints;

  RechargeHistoryModel({
    required this.historyID,
    required this.rechargeID,
    required this.amount,
    required this.points,
    required this.rechargeDate,
    required this.validTillDate,
    required this.paymentID,
    required this.lastRechargeNegativePoints,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory RechargeHistoryModel.fromJson(Map<String, dynamic> json) {
    return RechargeHistoryModel(
      historyID: json['history_id'],
      rechargeID: json['recharge_id'],
      amount: json['amount'],
      points: json['allotted_points'],
      rechargeDate: json['date'],
      validTillDate: json['valid_till_date'],
      paymentID: json['payment_id'],
      lastRechargeNegativePoints: json['last_recharge_negative_points'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'history_id': historyID,
      'recharge_id': rechargeID,
      'amount': amount,
      'allotted_points': points,
      'date': rechargeDate,
      'valid_till_date': validTillDate,
      'payment_id': paymentID,
      'last_recharge_negative_points': lastRechargeNegativePoints,
    };
  }
}
