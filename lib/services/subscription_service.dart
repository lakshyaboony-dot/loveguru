import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import '../models/user_model.dart';

class SubscriptionService {
  static const String _subscriptionKey = 'user_subscription';
  static const String _userKey = 'current_user';
  
  static SubscriptionService? _instance;
  static SubscriptionService get instance => _instance ??= SubscriptionService._();
  
  SubscriptionService._();

  // Get current user subscription
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString(_subscriptionKey);
      
      if (subscriptionJson != null) {
        final subscriptionData = jsonDecode(subscriptionJson);
        return SubscriptionModel.fromJson(subscriptionData);
      }
      return null;
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  // Save subscription data
  Future<bool> saveSubscription(SubscriptionModel subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = jsonEncode(subscription.toJson());
      return await prefs.setString(_subscriptionKey, subscriptionJson);
    } catch (e) {
      print('Error saving subscription: $e');
      return false;
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final subscription = await getCurrentSubscription();
    return subscription?.isActive ?? false;
  }

  // Get subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final subscription = await getCurrentSubscription();
    if (subscription == null) {
      return SubscriptionStatus.pending;
    }
    
    // Check if subscription has expired
    if (subscription.status == SubscriptionStatus.active && 
        DateTime.now().isAfter(subscription.endDate)) {
      // Update status to expired
      final expiredSubscription = subscription.copyWith(
        status: SubscriptionStatus.expired,
        updatedAt: DateTime.now(),
      );
      await saveSubscription(expiredSubscription);
      return SubscriptionStatus.expired;
    }
    
    return subscription.status;
  }

  // Create new subscription
  Future<SubscriptionModel> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required double amount,
    required int durationDays,
    String? paymentId,
    String? paymentMethod,
  }) async {
    final now = DateTime.now();
    final subscription = SubscriptionModel(
      subscriptionId: 'sub_${now.millisecondsSinceEpoch}',
      userId: userId,
      plan: plan,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: now.add(Duration(days: durationDays)),
      amount: amount,
      paymentId: paymentId,
      paymentMethod: paymentMethod,
      createdAt: now,
      features: _getPlanFeatures(plan),
    );
    
    await saveSubscription(subscription);
    return subscription;
  }

  // Get plan features
  Map<String, dynamic> _getPlanFeatures(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return {
          'dailyQuestions': 3,
          'voiceMessages': false,
          'compatibility': false,
          'horoscope': false,
          'tips': false,
        };
      case SubscriptionPlan.basic:
        return {
          'dailyQuestions': 10,
          'voiceMessages': true,
          'compatibility': true,
          'horoscope': false,
          'tips': false,
        };
      case SubscriptionPlan.premium:
        return {
          'dailyQuestions': 50,
          'voiceMessages': true,
          'compatibility': true,
          'horoscope': true,
          'tips': true,
        };
      case SubscriptionPlan.vip:
        return {
          'dailyQuestions': -1, // unlimited
          'voiceMessages': true,
          'compatibility': true,
          'horoscope': true,
          'tips': true,
          'priority': true,
        };
    }
  }

  // Check if feature is available
  Future<bool> isFeatureAvailable(String feature) async {
    final subscription = await getCurrentSubscription();
    if (subscription == null || !subscription.isActive) {
      // Free plan features
      final freeFeatures = _getPlanFeatures(SubscriptionPlan.free);
      return freeFeatures[feature] == true;
    }
    
    final features = subscription.features ?? {};
    return features[feature] == true || features[feature] == -1;
  }

  // Get remaining daily questions
  Future<int> getRemainingDailyQuestions() async {
    final subscription = await getCurrentSubscription();
    if (subscription == null || !subscription.isActive) {
      return _getPlanFeatures(SubscriptionPlan.free)['dailyQuestions'];
    }
    
    final features = subscription.features ?? {};
    final dailyLimit = features['dailyQuestions'] ?? 3;
    
    if (dailyLimit == -1) return -1; // unlimited
    
    // Get today's usage (you can implement usage tracking)
    final todayUsage = await getTodayUsage();
    return (dailyLimit - todayUsage).clamp(0, dailyLimit);
  }

  // Get today's usage (placeholder - implement based on your needs)
  Future<int> getTodayUsage() async {
    // This should track daily usage from your usage tracking system
    // For now, returning 0
    return 0;
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    final subscription = await getCurrentSubscription();
    if (subscription == null) return false;
    
    final cancelledSubscription = subscription.copyWith(
      status: SubscriptionStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    
    return await saveSubscription(cancelledSubscription);
  }

  // Get subscription plans with pricing
  List<Map<String, dynamic>> getSubscriptionPlans() {
    return [
      {
        'plan': SubscriptionPlan.basic,
        'name': 'बेसिक प्लान',
        'nameEnglish': 'Basic Plan',
        'price': 99.0,
        'duration': 30,
        'features': [
          '10 दैनिक प्रश्न',
          'वॉयस मैसेज',
          'राशि मिलान',
        ],
      },
      {
        'plan': SubscriptionPlan.premium,
        'name': 'प्रीमियम प्लान',
        'nameEnglish': 'Premium Plan',
        'price': 199.0,
        'duration': 30,
        'features': [
          '50 दैनिक प्रश्न',
          'वॉयस मैसेज',
          'राशि मिलान',
          'दैनिक राशिफल',
          'रिश्ते की सलाह',
        ],
      },
      {
        'plan': SubscriptionPlan.vip,
        'name': 'वीआईपी प्लान',
        'nameEnglish': 'VIP Plan',
        'price': 499.0,
        'duration': 30,
        'features': [
          'असीमित प्रश्न',
          'वॉयस मैसेज',
          'राशि मिलान',
          'दैनिक राशिफल',
          'रिश्ते की सलाह',
          'प्राथमिकता सपोर्ट',
        ],
      },
    ];
  }

  // Clear subscription data (for logout)
  Future<bool> clearSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionKey);
      return true;
    } catch (e) {
      print('Error clearing subscription data: $e');
      return false;
    }
  }
}