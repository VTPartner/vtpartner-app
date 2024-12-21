class AllRechargesModel {
  final int rechargeId;
  final double amount;
  final int points;
  final int status;
  final String validDays;
  final String description;

  AllRechargesModel({
    required this.rechargeId,
    required this.amount,
    required this.points,
    required this.status,
    required this.validDays,
    required this.description,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllRechargesModel.fromJson(Map<String, dynamic> json) {
    return AllRechargesModel(
      rechargeId: json['recharge_id'],
      amount: json['amount'],
      points: json['points'],
      status: json['status'],
      validDays: json['valid_days'],
      description: json['description'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'recharge_id': rechargeId,
      'amount': amount,
      'points': points,
      'status': status,
      'valid_days': validDays,
      'description': description,
    };
  }
}
