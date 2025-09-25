import 'package:flutter/material.dart';
import '../services/astrology_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({Key? key}) : super(key: key);

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  String? _selectedSign1;
  String? _selectedSign2;
  bool _isLoading = false;
  Map<String, dynamic>? _compatibilityResult;
  int _compatibilityPercentage = 0;
  String _compatibilityMessage = '';
  String _advice = '';
  bool _showResult = false;

  final List<Map<String, String>> _zodiacSigns = [
    {'name': 'Aries', 'hindi': 'मेष', 'symbol': '♈'},
    {'name': 'Taurus', 'hindi': 'वृषभ', 'symbol': '♉'},
    {'name': 'Gemini', 'hindi': 'मिथुन', 'symbol': '♊'},
    {'name': 'Cancer', 'hindi': 'कर्क', 'symbol': '♋'},
    {'name': 'Leo', 'hindi': 'सिंह', 'symbol': '♌'},
    {'name': 'Virgo', 'hindi': 'कन्या', 'symbol': '♍'},
    {'name': 'Libra', 'hindi': 'तुला', 'symbol': '♎'},
    {'name': 'Scorpio', 'hindi': 'वृश्चिक', 'symbol': '♏'},
    {'name': 'Sagittarius', 'hindi': 'धनु', 'symbol': '♐'},
    {'name': 'Capricorn', 'hindi': 'मकर', 'symbol': '♑'},
    {'name': 'Aquarius', 'hindi': 'कुम्भ', 'symbol': '♒'},
    {'name': 'Pisces', 'hindi': 'मीन', 'symbol': '♓'},
  ];

  void _calculateCompatibility() async {
    print('DEBUG: _calculateCompatibility called');
    print('DEBUG: _selectedSign1 = $_selectedSign1');
    print('DEBUG: _selectedSign2 = $_selectedSign2');
    
    if (_selectedSign1 == null || _selectedSign2 == null) {
      print('DEBUG: One or both signs are null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both zodiac signs')),
      );
      return;
    }

    print('DEBUG: Setting loading state to true');
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert sign names to lowercase for API compatibility
      final sign1Lower = _selectedSign1!.toLowerCase();
      final sign2Lower = _selectedSign2!.toLowerCase();
      
      print('DEBUG: Calling API with signs: $sign1Lower, $sign2Lower');
      final result = await AstrologyApiService.getCompatibility(sign1Lower, sign2Lower);
      print('DEBUG: API result: $result');
      
      if (result['success']) {
        print('DEBUG: API call successful, updating UI');
        setState(() {
          _compatibilityPercentage = result['compatibility_percentage'];
          _compatibilityMessage = result['description'];
          _advice = result['advice'];
          _isLoading = false;
          _showResult = true;
        });
        print('DEBUG: UI updated successfully');
      } else {
        print('DEBUG: API call failed: ${result['error']}');
        throw Exception(result['error']);
      }
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Map<String, dynamic> _calculateZodiacCompatibility(String sign1, String sign2) {
    // Compatibility matrix based on astrological principles
    final compatibilityMatrix = {
      'Aries': {'Aries': 85, 'Taurus': 60, 'Gemini': 88, 'Cancer': 65, 'Leo': 95, 'Virgo': 70, 'Libra': 85, 'Scorpio': 75, 'Sagittarius': 90, 'Capricorn': 65, 'Aquarius': 80, 'Pisces': 70},
      'Taurus': {'Aries': 60, 'Taurus': 80, 'Gemini': 65, 'Cancer': 90, 'Leo': 70, 'Virgo': 95, 'Libra': 75, 'Scorpio': 85, 'Sagittarius': 60, 'Capricorn': 90, 'Aquarius': 65, 'Pisces': 85},
      'Gemini': {'Aries': 88, 'Taurus': 65, 'Gemini': 85, 'Cancer': 70, 'Leo': 85, 'Virgo': 75, 'Libra': 95, 'Scorpio': 70, 'Sagittarius': 85, 'Capricorn': 60, 'Aquarius': 90, 'Pisces': 75},
      'Cancer': {'Aries': 65, 'Taurus': 90, 'Gemini': 70, 'Cancer': 85, 'Leo': 75, 'Virgo': 85, 'Libra': 70, 'Scorpio': 95, 'Sagittarius': 65, 'Capricorn': 80, 'Aquarius': 60, 'Pisces': 90},
      'Leo': {'Aries': 95, 'Taurus': 70, 'Gemini': 85, 'Cancer': 75, 'Leo': 80, 'Virgo': 65, 'Libra': 85, 'Scorpio': 80, 'Sagittarius': 95, 'Capricorn': 70, 'Aquarius': 85, 'Pisces': 75},
      'Virgo': {'Aries': 70, 'Taurus': 95, 'Gemini': 75, 'Cancer': 85, 'Leo': 65, 'Virgo': 80, 'Libra': 75, 'Scorpio': 85, 'Sagittarius': 70, 'Capricorn': 95, 'Aquarius': 70, 'Pisces': 80},
      'Libra': {'Aries': 85, 'Taurus': 75, 'Gemini': 95, 'Cancer': 70, 'Leo': 85, 'Virgo': 75, 'Libra': 80, 'Scorpio': 75, 'Sagittarius': 85, 'Capricorn': 70, 'Aquarius': 95, 'Pisces': 80},
      'Scorpio': {'Aries': 75, 'Taurus': 85, 'Gemini': 70, 'Cancer': 95, 'Leo': 80, 'Virgo': 85, 'Libra': 75, 'Scorpio': 85, 'Sagittarius': 70, 'Capricorn': 80, 'Aquarius': 65, 'Pisces': 95},
      'Sagittarius': {'Aries': 90, 'Taurus': 60, 'Gemini': 85, 'Cancer': 65, 'Leo': 95, 'Virgo': 70, 'Libra': 85, 'Scorpio': 70, 'Sagittarius': 80, 'Capricorn': 65, 'Aquarius': 90, 'Pisces': 75},
      'Capricorn': {'Aries': 65, 'Taurus': 90, 'Gemini': 60, 'Cancer': 80, 'Leo': 70, 'Virgo': 95, 'Libra': 70, 'Scorpio': 80, 'Sagittarius': 65, 'Capricorn': 85, 'Aquarius': 75, 'Pisces': 85},
      'Aquarius': {'Aries': 80, 'Taurus': 65, 'Gemini': 90, 'Cancer': 60, 'Leo': 85, 'Virgo': 70, 'Libra': 95, 'Scorpio': 65, 'Sagittarius': 90, 'Capricorn': 75, 'Aquarius': 85, 'Pisces': 70},
      'Pisces': {'Aries': 70, 'Taurus': 85, 'Gemini': 75, 'Cancer': 90, 'Leo': 75, 'Virgo': 80, 'Libra': 80, 'Scorpio': 95, 'Sagittarius': 75, 'Capricorn': 85, 'Aquarius': 70, 'Pisces': 85},
    };

    final score = compatibilityMatrix[sign1]?[sign2] ?? 75;
    
    String message;
    String hindiMessage;
    
    if (score >= 90) {
      message = "Perfect Match! You two are made for each other.";
      hindiMessage = "परफेक्ट मैच! आप दोनों एक-दूसरे के लिए बने हैं।";
    } else if (score >= 80) {
      message = "Excellent compatibility! Great potential for a lasting relationship.";
      hindiMessage = "बेहतरीन compatibility! लंबे रिश्ते की अच्छी संभावना।";
    } else if (score >= 70) {
      message = "Good match! With understanding, this can work beautifully.";
      hindiMessage = "अच्छी जोड़ी! समझदारी से यह खूबसूरत रिश्ता बन सकता है।";
    } else if (score >= 60) {
      message = "Moderate compatibility. Requires effort from both sides.";
      hindiMessage = "मध्यम compatibility। दोनों तरफ से मेहनत की जरूरत।";
    } else {
      message = "Challenging match. Success requires patience and understanding.";
      hindiMessage = "चुनौतीपूर्ण जोड़ी। सफलता के लिए धैर्य और समझ चाहिए।";
    }

    return {
      'score': score,
      'message': message,
      'hindiMessage': hindiMessage,
      'sign1': sign1,
      'sign2': sign2,
      'advice': _getCompatibilityAdvice(sign1, sign2, score),
    };
  }

  String _getCompatibilityAdvice(String sign1, String sign2, int score) {
    if (score >= 80) {
      return "आप दोनों की जोड़ी बहुत अच्छी है। एक-दूसरे का साथ दें और खुश रहें। / Your pair is excellent. Support each other and stay happy.";
    } else if (score >= 60) {
      return "थोड़ी मेहनत से आप दोनों का रिश्ता और भी मजबूत हो सकता है। / With a little effort, your relationship can become even stronger.";
    } else {
      return "धैर्य रखें और एक-दूसरे को समझने की कोशिश करें। / Be patient and try to understand each other.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compatibility Prediction ✨',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade400,
              Colors.indigo.shade300,
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
                          '🔮 Zodiac Compatibility 🔮',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'अपनी और अपने साथी की राशि चुनें\nSelect your and your partner\'s zodiac signs',
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
                
                // Zodiac Selection
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // First Zodiac Sign
                        DropdownButtonFormField<String>(
                          value: _selectedSign1,
                          decoration: InputDecoration(
                            labelText: 'आपकी राशि / Your Zodiac Sign',
                            prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.deepPurple),
                            ),
                          ),
                          items: _zodiacSigns.map((sign) {
                            return DropdownMenuItem<String>(
                              value: sign['name'],
                              child: Text('${sign['symbol']} ${sign['name']} (${sign['hindi']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSign1 = value;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Second Zodiac Sign
                        DropdownButtonFormField<String>(
                          value: _selectedSign2,
                          decoration: InputDecoration(
                            labelText: 'साथी की राशि / Partner\'s Zodiac Sign',
                            prefixIcon: const Icon(Icons.favorite, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.deepPurple),
                            ),
                          ),
                          items: _zodiacSigns.map((sign) {
                            return DropdownMenuItem<String>(
                              value: sign['name'],
                              child: Text('${sign['symbol']} ${sign['name']} (${sign['hindi']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSign2 = value;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Check Compatibility Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _calculateCompatibility,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade400,
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
                                        'Analyzing... 🔮',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Check Compatibility ✨',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Result Card
                if (_compatibilityResult != null)
                  Expanded(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade100,
                              Colors.indigo.shade100,
                            ],
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Zodiac Signs Display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        _zodiacSigns.firstWhere((sign) => sign['name'] == _compatibilityResult!['sign1'])['symbol']!,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                      Text(
                                        _compatibilityResult!['sign1'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '💕',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        _zodiacSigns.firstWhere((sign) => sign['name'] == _compatibilityResult!['sign2'])['symbol']!,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                      Text(
                                        _compatibilityResult!['sign2'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Compatibility Score
                              Text(
                                '${_compatibilityResult!['score']}%',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade600,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Progress Bar
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade300,
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _compatibilityResult!['score'] / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade400,
                                          Colors.indigo.shade400,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Messages
                              Text(
                                _compatibilityResult!['message'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 15),
                              
                              Text(
                                _compatibilityResult!['hindiMessage'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Advice
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _compatibilityResult!['advice'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
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
}