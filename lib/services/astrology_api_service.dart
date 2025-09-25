import 'dart:convert';
import 'package:http/http.dart' as http;

class AstrologyApiService {
  // Using a free astrology API service
  static const String _baseUrl = 'https://json.astrologyapi.com/v1';
  static const String _userId = 'demo_user'; // Replace with actual user ID
  static const String _apiKey = 'demo_key'; // Replace with actual API key
  
  // For demo purposes, we'll use local data
  static const Map<String, Map<String, dynamic>> _zodiacCompatibility = {
    'aries': {
      'aries': {'percentage': 85, 'description': 'High energy match'},
      'taurus': {'percentage': 60, 'description': 'Opposite attracts'},
      'gemini': {'percentage': 90, 'description': 'Perfect intellectual match'},
      'cancer': {'percentage': 45, 'description': 'Challenging but possible'},
      'leo': {'percentage': 95, 'description': 'Fire meets fire - explosive!'},
      'virgo': {'percentage': 55, 'description': 'Different approaches'},
      'libra': {'percentage': 80, 'description': 'Balanced partnership'},
      'scorpio': {'percentage': 70, 'description': 'Intense connection'},
      'sagittarius': {'percentage': 88, 'description': 'Adventure partners'},
      'capricorn': {'percentage': 50, 'description': 'Work vs play'},
      'aquarius': {'percentage': 75, 'description': 'Innovative together'},
      'pisces': {'percentage': 65, 'description': 'Creative harmony'},
    },
    'taurus': {
      'aries': {'percentage': 60, 'description': 'Opposite attracts'},
      'taurus': {'percentage': 80, 'description': 'Stable and secure'},
      'gemini': {'percentage': 55, 'description': 'Different paces'},
      'cancer': {'percentage': 90, 'description': 'Nurturing love'},
      'leo': {'percentage': 65, 'description': 'Luxury lovers'},
      'virgo': {'percentage': 95, 'description': 'Earth sign harmony'},
      'libra': {'percentage': 85, 'description': 'Beauty and comfort'},
      'scorpio': {'percentage': 75, 'description': 'Deep sensuality'},
      'sagittarius': {'percentage': 45, 'description': 'Freedom vs security'},
      'capricorn': {'percentage': 92, 'description': 'Building together'},
      'aquarius': {'percentage': 50, 'description': 'Traditional vs modern'},
      'pisces': {'percentage': 88, 'description': 'Gentle romance'},
    },
    'gemini': {
      'aries': {'percentage': 90, 'description': 'Perfect intellectual match'},
      'taurus': {'percentage': 55, 'description': 'Different paces'},
      'gemini': {'percentage': 75, 'description': 'Mental stimulation'},
      'cancer': {'percentage': 60, 'description': 'Mind vs heart'},
      'leo': {'percentage': 85, 'description': 'Fun and games'},
      'virgo': {'percentage': 70, 'description': 'Analytical minds'},
      'libra': {'percentage': 95, 'description': 'Air sign perfection'},
      'scorpio': {'percentage': 55, 'description': 'Surface vs depth'},
      'sagittarius': {'percentage': 88, 'description': 'Philosophical talks'},
      'capricorn': {'percentage': 45, 'description': 'Serious vs playful'},
      'aquarius': {'percentage': 92, 'description': 'Innovative ideas'},
      'pisces': {'percentage': 65, 'description': 'Logic vs intuition'},
    },
    'cancer': {
      'aries': {'percentage': 45, 'description': 'Challenging but possible'},
      'taurus': {'percentage': 90, 'description': 'Nurturing love'},
      'gemini': {'percentage': 60, 'description': 'Mind vs heart'},
      'cancer': {'percentage': 85, 'description': 'Emotional understanding'},
      'leo': {'percentage': 70, 'description': 'Caring for the king'},
      'virgo': {'percentage': 88, 'description': 'Practical care'},
      'libra': {'percentage': 75, 'description': 'Harmonious home'},
      'scorpio': {'percentage': 95, 'description': 'Water sign intensity'},
      'sagittarius': {'percentage': 50, 'description': 'Home vs adventure'},
      'capricorn': {'percentage': 80, 'description': 'Traditional values'},
      'aquarius': {'percentage': 55, 'description': 'Emotion vs detachment'},
      'pisces': {'percentage': 92, 'description': 'Intuitive connection'},
    },
    'leo': {
      'aries': {'percentage': 95, 'description': 'Fire meets fire - explosive!'},
      'taurus': {'percentage': 65, 'description': 'Luxury lovers'},
      'gemini': {'percentage': 85, 'description': 'Fun and games'},
      'cancer': {'percentage': 70, 'description': 'Caring for the king'},
      'leo': {'percentage': 80, 'description': 'Royal couple'},
      'virgo': {'percentage': 60, 'description': 'Drama vs practicality'},
      'libra': {'percentage': 90, 'description': 'Beautiful partnership'},
      'scorpio': {'percentage': 75, 'description': 'Power struggle'},
      'sagittarius': {'percentage': 92, 'description': 'Adventure and fun'},
      'capricorn': {'percentage': 55, 'description': 'Show vs substance'},
      'aquarius': {'percentage': 78, 'description': 'Creative expression'},
      'pisces': {'percentage': 68, 'description': 'Fire and water'},
    },
    'virgo': {
      'aries': {'percentage': 55, 'description': 'Different approaches'},
      'taurus': {'percentage': 95, 'description': 'Earth sign harmony'},
      'gemini': {'percentage': 70, 'description': 'Analytical minds'},
      'cancer': {'percentage': 88, 'description': 'Practical care'},
      'leo': {'percentage': 60, 'description': 'Drama vs practicality'},
      'virgo': {'percentage': 85, 'description': 'Perfectionist pair'},
      'libra': {'percentage': 75, 'description': 'Refined tastes'},
      'scorpio': {'percentage': 80, 'description': 'Deep analysis'},
      'sagittarius': {'percentage': 58, 'description': 'Detail vs big picture'},
      'capricorn': {'percentage': 92, 'description': 'Practical partnership'},
      'aquarius': {'percentage': 65, 'description': 'Method vs innovation'},
      'pisces': {'percentage': 78, 'description': 'Service and compassion'},
    },
    'libra': {
      'aries': {'percentage': 80, 'description': 'Balanced partnership'},
      'taurus': {'percentage': 85, 'description': 'Beauty and comfort'},
      'gemini': {'percentage': 95, 'description': 'Air sign perfection'},
      'cancer': {'percentage': 75, 'description': 'Harmonious home'},
      'leo': {'percentage': 90, 'description': 'Beautiful partnership'},
      'virgo': {'percentage': 75, 'description': 'Refined tastes'},
      'libra': {'percentage': 80, 'description': 'Perfect balance'},
      'scorpio': {'percentage': 70, 'description': 'Beauty and intensity'},
      'sagittarius': {'percentage': 85, 'description': 'Social adventures'},
      'capricorn': {'percentage': 68, 'description': 'Style vs substance'},
      'aquarius': {'percentage': 88, 'description': 'Intellectual harmony'},
      'pisces': {'percentage': 82, 'description': 'Artistic souls'},
    },
    'scorpio': {
      'aries': {'percentage': 70, 'description': 'Intense connection'},
      'taurus': {'percentage': 75, 'description': 'Deep sensuality'},
      'gemini': {'percentage': 55, 'description': 'Surface vs depth'},
      'cancer': {'percentage': 95, 'description': 'Water sign intensity'},
      'leo': {'percentage': 75, 'description': 'Power struggle'},
      'virgo': {'percentage': 80, 'description': 'Deep analysis'},
      'libra': {'percentage': 70, 'description': 'Beauty and intensity'},
      'scorpio': {'percentage': 85, 'description': 'Intense passion'},
      'sagittarius': {'percentage': 60, 'description': 'Depth vs freedom'},
      'capricorn': {'percentage': 88, 'description': 'Power couple'},
      'aquarius': {'percentage': 58, 'description': 'Intensity vs detachment'},
      'pisces': {'percentage': 92, 'description': 'Psychic connection'},
    },
    'sagittarius': {
      'aries': {'percentage': 88, 'description': 'Adventure partners'},
      'taurus': {'percentage': 45, 'description': 'Freedom vs security'},
      'gemini': {'percentage': 88, 'description': 'Philosophical talks'},
      'cancer': {'percentage': 50, 'description': 'Home vs adventure'},
      'leo': {'percentage': 92, 'description': 'Adventure and fun'},
      'virgo': {'percentage': 58, 'description': 'Detail vs big picture'},
      'libra': {'percentage': 85, 'description': 'Social adventures'},
      'scorpio': {'percentage': 60, 'description': 'Depth vs freedom'},
      'sagittarius': {'percentage': 80, 'description': 'Freedom lovers'},
      'capricorn': {'percentage': 55, 'description': 'Adventure vs responsibility'},
      'aquarius': {'percentage': 90, 'description': 'Future visionaries'},
      'pisces': {'percentage': 68, 'description': 'Dreams and adventures'},
    },
    'capricorn': {
      'aries': {'percentage': 50, 'description': 'Work vs play'},
      'taurus': {'percentage': 92, 'description': 'Building together'},
      'gemini': {'percentage': 45, 'description': 'Serious vs playful'},
      'cancer': {'percentage': 80, 'description': 'Traditional values'},
      'leo': {'percentage': 55, 'description': 'Show vs substance'},
      'virgo': {'percentage': 92, 'description': 'Practical partnership'},
      'libra': {'percentage': 68, 'description': 'Style vs substance'},
      'scorpio': {'percentage': 88, 'description': 'Power couple'},
      'sagittarius': {'percentage': 55, 'description': 'Adventure vs responsibility'},
      'capricorn': {'percentage': 85, 'description': 'Ambitious pair'},
      'aquarius': {'percentage': 60, 'description': 'Traditional vs progressive'},
      'pisces': {'percentage': 75, 'description': 'Structure and dreams'},
    },
    'aquarius': {
      'aries': {'percentage': 75, 'description': 'Innovative together'},
      'taurus': {'percentage': 50, 'description': 'Traditional vs modern'},
      'gemini': {'percentage': 92, 'description': 'Innovative ideas'},
      'cancer': {'percentage': 55, 'description': 'Emotion vs detachment'},
      'leo': {'percentage': 78, 'description': 'Creative expression'},
      'virgo': {'percentage': 65, 'description': 'Method vs innovation'},
      'libra': {'percentage': 88, 'description': 'Intellectual harmony'},
      'scorpio': {'percentage': 58, 'description': 'Intensity vs detachment'},
      'sagittarius': {'percentage': 90, 'description': 'Future visionaries'},
      'capricorn': {'percentage': 60, 'description': 'Traditional vs progressive'},
      'aquarius': {'percentage': 80, 'description': 'Unique minds'},
      'pisces': {'percentage': 72, 'description': 'Innovation and intuition'},
    },
    'pisces': {
      'aries': {'percentage': 65, 'description': 'Creative harmony'},
      'taurus': {'percentage': 88, 'description': 'Gentle romance'},
      'gemini': {'percentage': 65, 'description': 'Logic vs intuition'},
      'cancer': {'percentage': 92, 'description': 'Intuitive connection'},
      'leo': {'percentage': 68, 'description': 'Fire and water'},
      'virgo': {'percentage': 78, 'description': 'Service and compassion'},
      'libra': {'percentage': 82, 'description': 'Artistic souls'},
      'scorpio': {'percentage': 92, 'description': 'Psychic connection'},
      'sagittarius': {'percentage': 68, 'description': 'Dreams and adventures'},
      'capricorn': {'percentage': 75, 'description': 'Structure and dreams'},
      'aquarius': {'percentage': 72, 'description': 'Innovation and intuition'},
      'pisces': {'percentage': 85, 'description': 'Dreamy romance'},
    },
  };

  static Future<Map<String, dynamic>> getCompatibility(String sign1, String sign2) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final compatibility = _zodiacCompatibility[sign1.toLowerCase()]?[sign2.toLowerCase()];
      
      if (compatibility != null) {
        return {
          'success': true,
          'compatibility_percentage': compatibility['percentage'],
          'description': compatibility['description'],
          'advice': _getAdvice(compatibility['percentage']),
        };
      } else {
        return {
          'success': false,
          'error': 'Zodiac signs not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get compatibility data: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getDailyHoroscope(String zodiacSign) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final horoscopes = {
        'aries': {
          'english': 'Today brings new opportunities in love. Be bold and express your feelings.',
          'hindi': 'आज प्रेम में नए अवसर आएंगे। साहसी बनें और अपनी भावनाएं व्यक्त करें।',
        },
        'taurus': {
          'english': 'Focus on building stable relationships. Your patience will be rewarded.',
          'hindi': 'स्थिर रिश्ते बनाने पर ध्यान दें। आपके धैर्य का फल मिलेगा।',
        },
        'gemini': {
          'english': 'Communication is key today. Share your thoughts with your loved ones.',
          'hindi': 'आज संवाद महत्वपूर्ण है। अपने प्रियजनों के साथ अपने विचार साझा करें।',
        },
        'cancer': {
          'english': 'Trust your intuition in matters of the heart. Family bonds strengthen.',
          'hindi': 'दिल की बातों में अपनी अंतर्दृष्टि पर भरोसा करें। पारिवारिक बंधन मजबूत होंगे।',
        },
        'leo': {
          'english': 'Your charisma attracts positive attention. Romance is in the air.',
          'hindi': 'आपका आकर्षण सकारात्मक ध्यान आकर्षित करता है। रोमांस हवा में है।',
        },
        'virgo': {
          'english': 'Pay attention to details in your relationships. Small gestures matter.',
          'hindi': 'अपने रिश्तों में विवरणों पर ध्यान दें। छोटे इशारे मायने रखते हैं।',
        },
        'libra': {
          'english': 'Harmony and balance bring peace to your love life. Seek compromise.',
          'hindi': 'सामंजस्य और संतुलन आपके प्रेम जीवन में शांति लाते हैं। समझौता खोजें।',
        },
        'scorpio': {
          'english': 'Deep emotional connections are highlighted. Embrace vulnerability.',
          'hindi': 'गहरे भावनात्मक संबंध उजागर होते हैं। कमजोरी को अपनाएं।',
        },
        'sagittarius': {
          'english': 'Adventure awaits in love. Be open to new experiences and people.',
          'hindi': 'प्रेम में रोमांच का इंतजार है। नए अनुभवों और लोगों के लिए खुले रहें।',
        },
        'capricorn': {
          'english': 'Commitment and dedication strengthen your bonds. Plan for the future.',
          'hindi': 'प्रतिबद्धता और समर्पण आपके बंधन को मजबूत करते हैं। भविष्य की योजना बनाएं।',
        },
        'aquarius': {
          'english': 'Unique connections form today. Embrace your individuality in love.',
          'hindi': 'आज अनोखे संबंध बनते हैं। प्रेम में अपनी व्यक्तिगतता को अपनाएं।',
        },
        'pisces': {
          'english': 'Dreams and reality merge in love. Trust your heart\'s guidance.',
          'hindi': 'प्रेम में सपने और वास्तविकता मिल जाते हैं। अपने दिल के मार्गदर्शन पर भरोसा करें।',
        },
      };

      final horoscope = horoscopes[zodiacSign.toLowerCase()];
      
      if (horoscope != null) {
        return {
          'success': true,
          'english_prediction': horoscope['english'],
          'hindi_prediction': horoscope['hindi'],
          'date': DateTime.now().toIso8601String().split('T')[0],
        };
      } else {
        return {
          'success': false,
          'error': 'Zodiac sign not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get horoscope: $e',
      };
    }
  }

  static String _getAdvice(int percentage) {
    if (percentage >= 90) {
      return 'Perfect match! You two are meant to be together.';
    } else if (percentage >= 80) {
      return 'Excellent compatibility! Great potential for a lasting relationship.';
    } else if (percentage >= 70) {
      return 'Good match with some effort. Communication is key.';
    } else if (percentage >= 60) {
      return 'Moderate compatibility. Focus on understanding each other.';
    } else if (percentage >= 50) {
      return 'Challenging but possible. Work on your differences.';
    } else {
      return 'Difficult match. Consider if you\'re truly compatible.';
    }
  }

  static String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else {
      return 'pisces';
    }
  }
}