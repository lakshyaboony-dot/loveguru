enum SubscriptionPlan {
  free,
  basic,
  premium,
  vip,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
}

class SubscriptionModel {
  final String subscriptionId;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String currency;
  final String? paymentId;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? features;

  SubscriptionModel({
    required this.subscriptionId,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.currency = 'INR',
    this.paymentId,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.features,
  });

  // Check if subscription is currently active
  bool get isActive {
    return status == SubscriptionStatus.active && 
           DateTime.now().isBefore(endDate);
  }

  // Get remaining days
  int get remainingDays {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  // Get plan name in Hindi
  String get planNameHindi {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'मुफ्त';
      case SubscriptionPlan.basic:
        return 'बेसिक';
      case SubscriptionPlan.premium:
        return 'प्रीमियम';
      case SubscriptionPlan.vip:
        return 'वीआईपी';
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'userId': userId,
      'plan': plan.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'features': features,
    };
  }

  // Create from JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      subscriptionId: json['subscriptionId'],
      userId: json['userId'],
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.pending,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'INR',
      paymentId: json['paymentId'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      features: json['features'],
    );
  }

  // Copy with method for updates
  SubscriptionModel copyWith({
    String? subscriptionId,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? amount,
    String? currency,
    String? paymentId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? features,
  }) {
    return SubscriptionModel(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      features: features ?? this.features,
    );
  }
}