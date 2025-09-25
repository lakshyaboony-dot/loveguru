import 'package:flutter/material.dart';
import 'dart:math';

class LoveMeterScreen extends StatefulWidget {
  const LoveMeterScreen({Key? key}) : super(key: key);

  @override
  State<LoveMeterScreen> createState() => _LoveMeterScreenState();
}

class _LoveMeterScreenState extends State<LoveMeterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  
  double _lovePercentage = 0.0;
  String _loveMessage = '';
  bool _isCalculating = false;
  bool _showResult = false;
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    _name1Controller.dispose();
    _name2Controller.dispose();
    super.dispose();
  }

  void _calculateLove() async {
    if (_name1Controller.text.trim().isEmpty || _name2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया दोनों नाम भरें / Please enter both names'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _showResult = false;
    });

    // Simulate calculation delay
    await Future.delayed(const Duration(seconds: 2));

    // Calculate love percentage using names
    final name1 = _name1Controller.text.trim().toLowerCase();
    final name2 = _name2Controller.text.trim().toLowerCase();
    
    // Simple algorithm based on name compatibility
    int compatibility = _calculateCompatibility(name1, name2);
    
    setState(() {
      _lovePercentage = compatibility.toDouble();
      _loveMessage = _getLoveMessage(compatibility);
      _isCalculating = false;
      _showResult = true;
    });

    _animationController.forward();
    _heartController.repeat(reverse: true);
  }

  int _calculateCompatibility(String name1, String name2) {
    // Advanced name compatibility algorithm
    int score = 0;
    
    // Check common letters
    Set<String> letters1 = name1.split('').toSet();
    Set<String> letters2 = name2.split('').toSet();
    int commonLetters = letters1.intersection(letters2).length;
    score += commonLetters * 8;
    
    // Length compatibility
    int lengthDiff = (name1.length - name2.length).abs();
    score += (10 - lengthDiff.clamp(0, 10)) * 3;
    
    // Vowel compatibility
    String vowels = 'aeiouअआइईउऊएऐओऔ';
    int vowels1 = name1.split('').where((c) => vowels.contains(c)).length;
    int vowels2 = name2.split('').where((c) => vowels.contains(c)).length;
    int vowelDiff = (vowels1 - vowels2).abs();
    score += (5 - vowelDiff.clamp(0, 5)) * 4;
    
    // Add some randomness for fun
    Random random = Random(name1.hashCode + name2.hashCode);
    score += random.nextInt(20);
    
    return score.clamp(10, 99);
  }

  String _getLoveMessage(int percentage) {
    if (percentage >= 90) {
      return 'Perfect Match! 💕\nआप दोनों एक-दूसरे के लिए बने हैं!';
    } else if (percentage >= 80) {
      return 'Excellent Compatibility! ❤️\nबहुत अच्छी जोड़ी है!';
    } else if (percentage >= 70) {
      return 'Very Good Match! 💖\nअच्छी compatibility है!';
    } else if (percentage >= 60) {
      return 'Good Potential! 💝\nअच्छी संभावनाएं हैं!';
    } else if (percentage >= 50) {
      return 'Average Match 💛\nकुछ मेहनत की जरूरत है!';
    } else if (percentage >= 40) {
      return 'Needs Work 💙\nरिश्ते में मेहनत करनी होगी!';
    } else {
      return 'Challenging Match 💜\nबहुत मेहनत की जरूरत है!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Love Meter 💕',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade400,
              Colors.purple.shade300,
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
                          '💖 Love Compatibility Test 💖',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'अपना और अपने साथी का नाम डालें\nEnter your and your partner\'s name',
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
                
                // Input Fields
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _name1Controller,
                          decoration: InputDecoration(
                            labelText: 'आपका नाम / Your Name',
                            prefixIcon: const Icon(Icons.person, color: Colors.pink),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.pink),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _name2Controller,
                          decoration: InputDecoration(
                            labelText: 'साथी का नाम / Partner\'s Name',
                            prefixIcon: const Icon(Icons.favorite, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.pink),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Calculate Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isCalculating ? null : _calculateLove,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                            ),
                            child: _isCalculating
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
                                        'Calculating... 💕',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Calculate Love 💖',
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
                if (_showResult)
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animation.value,
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
                                    Colors.pink.shade100,
                                    Colors.purple.shade100,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _heartAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _heartAnimation.value,
                                        child: Text(
                                          '💖',
                                          style: TextStyle(fontSize: 50),
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  Text(
                                    '${_lovePercentage.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade600,
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
                                      widthFactor: _lovePercentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.pink.shade400,
                                              Colors.red.shade400,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 30),
                                  
                                  Text(
                                    _loveMessage,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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