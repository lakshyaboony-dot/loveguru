import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/astrology_api_service.dart';
import '../services/usage_limit_service.dart';
import '../services/subscription_service.dart';
import '../screens/payment_screen.dart';
import 'subscription_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DateOfBirthScreen extends StatefulWidget {
  const DateOfBirthScreen({Key? key}) : super(key: key);

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  DateTime? _selectedDate;
  String? _zodiacSign;
  String? _zodiacHindi;
  String? _zodiacSymbol;
  bool _isLoading = false;
  Map<String, dynamic>? _predictions;
  final UsageLimitService _usageService = UsageLimitService();
  final SubscriptionService _subscriptionService = SubscriptionService.instance;

  final Map<String, Map<String, String>> _zodiacData = {
    'aries': {'hindi': 'मेष', 'symbol': '♈'},
    'taurus': {'hindi': 'वृषभ', 'symbol': '♉'},
    'gemini': {'hindi': 'मिथुन', 'symbol': '♊'},
    'cancer': {'hindi': 'कर्क', 'symbol': '♋'},
    'leo': {'hindi': 'सिंह', 'symbol': '♌'},
    'virgo': {'hindi': 'कन्या', 'symbol': '♍'},
    'libra': {'hindi': 'तुला', 'symbol': '♎'},
    'scorpio': {'hindi': 'वृश्चिक', 'symbol': '♏'},
    'sagittarius': {'hindi': 'धनु', 'symbol': '♐'},
    'capricorn': {'hindi': 'मकर', 'symbol': '♑'},
    'aquarius': {'hindi': 'कुम्भ', 'symbol': '♒'},
    'pisces': {'hindi': 'मीन', 'symbol': '♓'},
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 7300)), // ~20 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _zodiacSign = null;
        _predictions = null;
      });
      _calculateZodiacSign();
    }
  }

  void _calculateZodiacSign() {
    if (_selectedDate == null) return;

    final month = _selectedDate!.month;
    final day = _selectedDate!.day;

    String sign;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      sign = 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      sign = 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      sign = 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      sign = 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      sign = 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      sign = 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      sign = 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      sign = 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      sign = 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      sign = 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      sign = 'aquarius';
    } else {
      sign = 'pisces';
    }

    setState(() {
      _zodiacSign = sign;
      _zodiacHindi = _zodiacData[sign]!['hindi'];
      _zodiacSymbol = _zodiacData[sign]!['symbol'];
    });
  }

  Future<void> _getPredictions() async {
    if (_zodiacSign == null) return;

    // Check subscription status first
    final hasActiveSubscription = await _subscriptionService.hasActiveSubscription();
    
    if (!hasActiveSubscription) {
      // Check usage limit for free users
      if (!await _usageService.canUsePrediction()) {
        _showUsageLimitDialog();
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _predictions = null;
    });

    try {
      // Get daily horoscope using AstrologyApiService
      final horoscopeResult = await AstrologyApiService.getDailyHoroscope(_zodiacSign!);
      
      if (horoscopeResult['success']) {
        setState(() {
          _predictions = {
            'description': horoscopeResult['english_prediction'] ?? 'Today brings new opportunities for love and relationships.',
            'compatibility': horoscopeResult['compatibility'] ?? 'Cancer',
            'mood': horoscopeResult['mood'] ?? 'Romantic',
            'color': horoscopeResult['color'] ?? 'Pink',
            'luckyNumber': horoscopeResult['lucky_number'] ?? '7',
            'luckyTime': horoscopeResult['lucky_time'] ?? '2:00 PM to 4:00 PM',
            'dateRange': horoscopeResult['date_range'] ?? '',
            'advice': horoscopeResult['hindi_prediction'] ?? 'अपने दिल की सुनें और निडर होकर प्यार करें।',
          };
          _isLoading = false;
        });
        
        // Update usage count only for free users
        if (!hasActiveSubscription) {
          await _usageService.incrementPredictionUsage();
        }
      } else {
        _generateLocalPredictions();
      }
    } catch (e) {
      _generateLocalPredictions();
    }
  }

  void _showUsageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text('You have reached your daily prediction limit. Upgrade to premium for unlimited predictions or wait until tomorrow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              );
            },
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  void _generateLocalPredictions() {
    // Generate local predictions based on zodiac sign
    final predictions = _getLocalPredictions(_zodiacSign!);
    setState(() {
      _predictions = predictions;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _getLocalPredictions(String sign) {
    final predictionData = {
      'aries': {
        'description': 'आज आपके प्रेम जीवन में नई शुरुआत हो सकती है। साहस के साथ आगे बढ़ें। Today brings new beginnings in your love life. Move forward with courage.',
        'compatibility': 'Leo, Sagittarius',
        'mood': 'Energetic & Passionate',
        'color': 'Red',
        'luckyNumber': '9',
        'luckyTime': '6:00 AM to 8:00 AM',
        'advice': 'अपने दिल की सुनें और निडर होकर प्यार करें। Listen to your heart and love fearlessly.',
      },
      'taurus': {
        'description': 'स्थिरता और धैर्य आपके रिश्तों को मजबूत बनाएगा। आज रोमांस का दिन है। Stability and patience will strengthen your relationships. Today is a day for romance.',
        'compatibility': 'Virgo, Capricorn',
        'mood': 'Calm & Romantic',
        'color': 'Green',
        'luckyNumber': '6',
        'luckyTime': '2:00 PM to 4:00 PM',
        'advice': 'धैर्य रखें और अपने साथी को समझें। Be patient and understand your partner.',
      },
      'gemini': {
        'description': 'संवाद और मित्रता आपके प्रेम जीवन में खुशियां लाएगी। नए लोगों से मिलें। Communication and friendship will bring joy to your love life. Meet new people.',
        'compatibility': 'Libra, Aquarius',
        'mood': 'Social & Curious',
        'color': 'Yellow',
        'luckyNumber': '5',
        'luckyTime': '10:00 AM to 12:00 PM',
        'advice': 'खुले दिल से बात करें और नए रिश्ते बनाएं। Communicate openly and build new relationships.',
      },
      'cancer': {
        'description': 'भावनाओं की गहराई आपके रिश्तों को और भी खूबसूरत बनाएगी। परिवार का साथ मिलेगा। Emotional depth will make your relationships more beautiful. Family support is coming.',
        'compatibility': 'Scorpio, Pisces',
        'mood': 'Emotional & Caring',
        'color': 'Silver',
        'luckyNumber': '2',
        'luckyTime': '7:00 PM to 9:00 PM',
        'advice': 'अपनी भावनाओं को व्यक्त करें और देखभाल करें। Express your emotions and show care.',
      },
      'leo': {
        'description': 'आपका आकर्षण और आत्मविश्वास आज चरम पर होगा। प्रेम में सफलता मिलेगी। Your charm and confidence will be at its peak today. Success in love awaits.',
        'compatibility': 'Aries, Sagittarius',
        'mood': 'Confident & Generous',
        'color': 'Gold',
        'luckyNumber': '1',
        'luckyTime': '12:00 PM to 2:00 PM',
        'advice': 'अपने आत्मविश्वास को बनाए रखें और उदार बनें। Maintain your confidence and be generous.',
      },
      'virgo': {
        'description': 'व्यावहारिकता और सेवा भावना आपके रिश्तों को मजबूत बनाएगी। छोटी बातों पर ध्यान दें। Practicality and service will strengthen your relationships. Pay attention to small details.',
        'compatibility': 'Taurus, Capricorn',
        'mood': 'Practical & Helpful',
        'color': 'Navy Blue',
        'luckyNumber': '6',
        'luckyTime': '8:00 AM to 10:00 AM',
        'advice': 'छोटी-छोटी बातों से प्यार जताएं। Show love through small gestures.',
      },
      'libra': {
        'description': 'संतुलन और सुंदरता आपके प्रेम जीवन में हार्मनी लाएगी। कलात्मक गतिविधियों में भाग लें। Balance and beauty will bring harmony to your love life. Engage in artistic activities.',
        'compatibility': 'Gemini, Aquarius',
        'mood': 'Harmonious & Artistic',
        'color': 'Pink',
        'luckyNumber': '7',
        'luckyTime': '4:00 PM to 6:00 PM',
        'advice': 'संतुलन बनाए रखें और सुंदरता की तारीफ करें। Maintain balance and appreciate beauty.',
      },
      'scorpio': {
        'description': 'गहन भावनाएं और जुनून आपके रिश्तों को नई ऊंचाई देगा। रहस्य खुलेंगे। Deep emotions and passion will elevate your relationships. Mysteries will unfold.',
        'compatibility': 'Cancer, Pisces',
        'mood': 'Intense & Mysterious',
        'color': 'Maroon',
        'luckyNumber': '8',
        'luckyTime': '9:00 PM to 11:00 PM',
        'advice': 'अपनी गहरी भावनाओं को साझा करें। Share your deep emotions.',
      },
      'sagittarius': {
        'description': 'साहसिक यात्रा और नए अनुभव आपके प्रेम जीवन में रोमांच लाएंगे। खुले दिमाग से सोचें। Adventurous journeys and new experiences will bring excitement to your love life. Think with an open mind.',
        'compatibility': 'Aries, Leo',
        'mood': 'Adventurous & Optimistic',
        'color': 'Purple',
        'luckyNumber': '9',
        'luckyTime': '11:00 AM to 1:00 PM',
        'advice': 'नए अनुभवों के लिए तैयार रहें। Be ready for new experiences.',
      },
      'capricorn': {
        'description': 'दृढ़ता और लक्ष्य की स्पष्टता आपके रिश्तों को स्थिर बनाएगी। धैर्य रखें। Determination and clear goals will stabilize your relationships. Be patient.',
        'compatibility': 'Taurus, Virgo',
        'mood': 'Determined & Responsible',
        'color': 'Brown',
        'luckyNumber': '10',
        'luckyTime': '5:00 AM to 7:00 AM',
        'advice': 'अपने लक्ष्यों पर ध्यान दें और जिम्मेदार बनें। Focus on your goals and be responsible.',
      },
      'aquarius': {
        'description': 'मित्रता और नवाचार आपके प्रेम जीवन में नई दिशा देगा। अलग तरीके से सोचें। Friendship and innovation will give new direction to your love life. Think differently.',
        'compatibility': 'Gemini, Libra',
        'mood': 'Innovative & Friendly',
        'color': 'Turquoise',
        'luckyNumber': '11',
        'luckyTime': '3:00 PM to 5:00 PM',
        'advice': 'दोस्ती को प्राथमिकता दें और नवाचार करें। Prioritize friendship and innovate.',
      },
      'pisces': {
        'description': 'कल्पना और सहानुभूति आपके रिश्तों में गहराई लाएगी। कलात्मक अभिव्यक्ति करें। Imagination and empathy will bring depth to your relationships. Express artistically.',
        'compatibility': 'Cancer, Scorpio',
        'mood': 'Dreamy & Compassionate',
        'color': 'Sea Green',
        'luckyNumber': '12',
        'luckyTime': '8:00 PM to 10:00 PM',
        'advice': 'अपनी कल्पना का उपयोग करें और दयालु बनें। Use your imagination and be compassionate.',
      },
    };

    return predictionData[sign] ?? predictionData['aries']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Love Predictions 💕',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade400,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade400,
              Colors.cyan.shade300,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Title Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          '🌟 Personalized Predictions 🌟',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'अपनी जन्म तारीख डालें और व्यक्तिगत भविष्यवाणी पाएं\nEnter your birth date for personalized predictions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Date Selection
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Date Picker Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today, color: Colors.white),
                            label: Text(
                              _selectedDate == null
                                  ? 'जन्म तारीख चुनें / Select Birth Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        
                        // Zodiac Sign Display
                        if (_zodiacSign != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _zodiacSymbol!,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Text(
                                      _zodiacSign!.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    Text(
                                      _zodiacHindi!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Get Predictions Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _getPredictions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Getting Predictions... 🔮',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Get My Predictions 🌟',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Predictions Result
                if (_predictions != null)
                  Expanded(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade50,
                              Colors.cyan.shade50,
                            ],
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header
                              Text(
                                'आपकी आज की भविष्यवाणी\nYour Today\'s Prediction',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Main Description
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _predictions!['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Prediction Details
                              _buildPredictionItem('🤝 Best Compatibility', _predictions!['compatibility']),
                              _buildPredictionItem('😊 Today\'s Mood', _predictions!['mood']),
                              _buildPredictionItem('🎨 Lucky Color', _predictions!['color']),
                              _buildPredictionItem('🔢 Lucky Number', _predictions!['luckyNumber']),
                              _buildPredictionItem('⏰ Lucky Time', _predictions!['luckyTime']),
                              
                              const SizedBox(height: 20),
                              
                              // Advice
                              if (_predictions!['advice'] != null)
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.orange.shade300),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '💡 सलाह / Advice',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _predictions!['advice'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}