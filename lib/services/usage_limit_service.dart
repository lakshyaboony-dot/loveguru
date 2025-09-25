import 'package:shared_preferences/shared_preferences.dart';

class UsageLimitService {
  static const String _chatCountKey = 'daily_chat_count';
  static const String _predictionCountKey = 'daily_prediction_count';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _isPremiumKey = 'is_premium';
  static const String _premiumExpiryKey = 'premium_expiry';
  
  static const int maxDailyChats = 10;
  static const int maxDailyPredictions = 1;

  Future<bool> canUseChat() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user is premium
    if (await _isPremiumActive()) {
      return true;
    }
    
    await _resetCountsIfNewDay();
    
    final chatCount = prefs.getInt(_chatCountKey) ?? 0;
    return chatCount < maxDailyChats;
  }

  Future<bool> canUsePrediction() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user is premium
    if (await _isPremiumActive()) {
      return true;
    }
    
    await _resetCountsIfNewDay();
    
    final predictionCount = prefs.getInt(_predictionCountKey) ?? 0;
    return predictionCount < maxDailyPredictions;
  }

  Future<void> incrementChatUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetCountsIfNewDay();
    
    final currentCount = prefs.getInt(_chatCountKey) ?? 0;
    await prefs.setInt(_chatCountKey, currentCount + 1);
  }

  Future<void> incrementPredictionUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetCountsIfNewDay();
    
    final currentCount = prefs.getInt(_predictionCountKey) ?? 0;
    await prefs.setInt(_predictionCountKey, currentCount + 1);
  }

  Future<int> getRemainingChats() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user is premium
    if (await _isPremiumActive()) {
      return maxDailyChats + 100; // Unlimited for premium users
    }
    
    await _resetCountsIfNewDay();
    
    final chatCount = prefs.getInt(_chatCountKey) ?? 0;
    return (maxDailyChats - chatCount).clamp(0, maxDailyChats);
  }

  Future<int> getRemainingPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user is premium
    if (await _isPremiumActive()) {
      return maxDailyPredictions + 100; // Unlimited for premium users
    }
    
    await _resetCountsIfNewDay();
    
    final predictionCount = prefs.getInt(_predictionCountKey) ?? 0;
    return (maxDailyPredictions - predictionCount).clamp(0, maxDailyPredictions);
  }

  static Future<void> _resetCountsIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastResetDate = prefs.getString(_lastResetDateKey);
    
    if (lastResetDate != today) {
      await prefs.setInt(_chatCountKey, 0);
      await prefs.setInt(_predictionCountKey, 0);
      await prefs.setString(_lastResetDateKey, today);
    }
  }

  static Future<bool> _isPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_isPremiumKey) ?? false;
    
    if (!isPremium) return false;
    
    final expiryString = prefs.getString(_premiumExpiryKey);
    if (expiryString == null) return false;
    
    final expiryDate = DateTime.parse(expiryString);
    return DateTime.now().isBefore(expiryDate);
  }

  static Future<void> activatePremium(int months) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(Duration(days: months * 30));
    
    await prefs.setBool(_isPremiumKey, true);
    await prefs.setString(_premiumExpiryKey, expiryDate.toIso8601String());
  }

  static Future<void> addTopupCredits(int chats, int predictions) async {
    final prefs = await SharedPreferences.getInstance();
    final currentChats = prefs.getInt('topup_chats') ?? 0;
    final currentPredictions = prefs.getInt('topup_predictions') ?? 0;
    
    await prefs.setInt('topup_chats', currentChats + chats);
    await prefs.setInt('topup_predictions', currentPredictions + predictions);
  }

  static Future<Map<String, dynamic>> getUsageStatus() async {
    final service = UsageLimitService();
    return {
      'remainingChats': await service.getRemainingChats(),
      'remainingPredictions': await service.getRemainingPredictions(),
      'isPremium': await _isPremiumActive(),
    };
  }
}