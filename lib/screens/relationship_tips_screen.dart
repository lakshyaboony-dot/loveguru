import 'package:flutter/material.dart';

class RelationshipTipsScreen extends StatefulWidget {
  const RelationshipTipsScreen({Key? key}) : super(key: key);

  @override
  State<RelationshipTipsScreen> createState() => _RelationshipTipsScreenState();
}

class _RelationshipTipsScreenState extends State<RelationshipTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final Map<String, List<Map<String, String>>> _relationshipTips = {
    'communication': [
      {
        'title': 'Active Listening',
        'hindi': 'सक्रिय श्रवण',
        'tip': 'Listen to understand, not to reply. Give your partner your full attention when they speak.',
        'hindiTip': 'जवाब देने के लिए नहीं, समझने के लिए सुनें। जब आपका साथी बोले तो पूरा ध्यान दें।',
      },
      {
        'title': 'Express Feelings',
        'hindi': 'भावनाएं व्यक्त करें',
        'tip': 'Share your emotions openly and honestly. Don\'t keep feelings bottled up inside.',
        'hindiTip': 'अपनी भावनाओं को खुले और ईमानदारी से साझा करें। भावनाओं को अंदर न दबाएं।',
      },
      {
        'title': 'Avoid Blame Game',
        'hindi': 'दोषारोपण से बचें',
        'tip': 'Use "I" statements instead of "You" statements when discussing problems.',
        'hindiTip': 'समस्याओं पर चर्चा करते समय "तुम" के बजाय "मैं" का प्रयोग करें।',
      },
      {
        'title': 'Regular Check-ins',
        'hindi': 'नियमित बातचीत',
        'tip': 'Schedule regular conversations about your relationship and feelings.',
        'hindiTip': 'अपने रिश्ते और भावनाओं के बारे में नियमित बातचीत का समय निकालें।',
      },
    ],
    'trust': [
      {
        'title': 'Be Transparent',
        'hindi': 'पारदर्शी बनें',
        'tip': 'Share your thoughts, plans, and concerns openly with your partner.',
        'hindiTip': 'अपने विचार, योजनाएं और चिंताओं को अपने साथी के साथ खुले में साझा करें।',
      },
      {
        'title': 'Keep Promises',
        'hindi': 'वादे निभाएं',
        'tip': 'Always follow through on your commitments, no matter how small.',
        'hindiTip': 'अपनी प्रतिबद्धताओं को हमेशा पूरा करें, चाहे वे कितनी भी छोटी हों।',
      },
      {
        'title': 'Admit Mistakes',
        'hindi': 'गलतियां मानें',
        'tip': 'Take responsibility for your errors and apologize sincerely.',
        'hindiTip': 'अपनी गलतियों की जिम्मेदारी लें और दिल से माफी मांगें।',
      },
      {
        'title': 'Give Benefit of Doubt',
        'hindi': 'संदेह का फायदा दें',
        'tip': 'Trust your partner\'s intentions and don\'t jump to negative conclusions.',
        'hindiTip': 'अपने साथी के इरादों पर भरोसा करें और नकारात्मक निष्कर्ष पर न पहुंचें।',
      },
    ],
    'romance': [
      {
        'title': 'Small Gestures',
        'hindi': 'छोटे इशारे',
        'tip': 'Surprise your partner with small, thoughtful gestures regularly.',
        'hindiTip': 'अपने साथी को नियमित रूप से छोटे, विचारशील इशारों से चौंकाएं।',
      },
      {
        'title': 'Quality Time',
        'hindi': 'गुणवत्तापूर्ण समय',
        'tip': 'Spend uninterrupted time together without distractions.',
        'hindiTip': 'बिना किसी बाधा के एक साथ निर्बाध समय बिताएं।',
      },
      {
        'title': 'Physical Affection',
        'hindi': 'शारीरिक स्नेह',
        'tip': 'Show love through hugs, kisses, and gentle touches throughout the day.',
        'hindiTip': 'दिन भर गले लगाने, चूमने और कोमल स्पर्श के माध्यम से प्यार दिखाएं।',
      },
      {
        'title': 'Romantic Dates',
        'hindi': 'रोमांटिक डेट्स',
        'tip': 'Plan special dates and create memorable experiences together.',
        'hindiTip': 'विशेष डेट्स की योजना बनाएं और एक साथ यादगार अनुभव बनाएं।',
      },
    ],
    'conflict': [
      {
        'title': 'Stay Calm',
        'hindi': 'शांत रहें',
        'tip': 'Take deep breaths and avoid raising your voice during arguments.',
        'hindiTip': 'बहस के दौरान गहरी सांस लें और अपनी आवाज ऊंची न करें।',
      },
      {
        'title': 'Focus on Issues',
        'hindi': 'मुद्दों पर ध्यान दें',
        'tip': 'Address the specific problem, not your partner\'s character.',
        'hindiTip': 'अपने साथी के चरित्र पर नहीं, बल्कि विशिष्ट समस्या पर ध्यान दें।',
      },
      {
        'title': 'Take Breaks',
        'hindi': 'ब्रेक लें',
        'tip': 'If emotions run high, take a break and return to the discussion later.',
        'hindiTip': 'यदि भावनाएं तेज हो जाएं, तो ब्रेक लें और बाद में चर्चा पर वापस आएं।',
      },
      {
        'title': 'Find Compromise',
        'hindi': 'समझौता खोजें',
        'tip': 'Look for win-win solutions where both partners feel heard.',
        'hindiTip': 'ऐसे समाधान खोजें जहां दोनों साथी सुने गए महसूस करें।',
      },
    ],
    'intimacy': [
      {
        'title': 'Emotional Connection',
        'hindi': 'भावनात्मक जुड़ाव',
        'tip': 'Build emotional intimacy through deep conversations and vulnerability.',
        'hindiTip': 'गहरी बातचीत और भेद्यता के माध्यम से भावनात्मक अंतरंगता बनाएं।',
      },
      {
        'title': 'Express Appreciation',
        'hindi': 'प्रशंसा व्यक्त करें',
        'tip': 'Regularly tell your partner what you love and appreciate about them.',
        'hindiTip': 'नियमित रूप से अपने साथी को बताएं कि आप उनमें क्या पसंद करते हैं।',
      },
      {
        'title': 'Create Rituals',
        'hindi': 'रीति-रिवाज बनाएं',
        'tip': 'Develop special rituals and traditions that are unique to your relationship.',
        'hindiTip': 'विशेष रीति-रिवाज और परंपराएं विकसित करें जो आपके रिश्ते के लिए अनूठी हों।',
      },
      {
        'title': 'Be Present',
        'hindi': 'उपस्थित रहें',
        'tip': 'Give your full attention when spending intimate moments together.',
        'hindiTip': 'अंतरंग क्षणों को एक साथ बिताते समय अपना पूरा ध्यान दें।',
      },
    ],
    'growth': [
      {
        'title': 'Support Dreams',
        'hindi': 'सपनों का समर्थन करें',
        'tip': 'Encourage your partner\'s goals and aspirations actively.',
        'hindiTip': 'अपने साथी के लक्ष्यों और आकांक्षाओं को सक्रिय रूप से प्रोत्साहित करें।',
      },
      {
        'title': 'Learn Together',
        'hindi': 'एक साथ सीखें',
        'tip': 'Try new activities and learn new skills as a couple.',
        'hindiTip': 'एक जोड़े के रूप में नई गतिविधियों की कोशिश करें और नए कौशल सीखें।',
      },
      {
        'title': 'Give Space',
        'hindi': 'स्थान दें',
        'tip': 'Allow your partner time for individual growth and interests.',
        'hindiTip': 'अपने साथी को व्यक्तिगत विकास और रुचियों के लिए समय दें।',
      },
      {
        'title': 'Celebrate Progress',
        'hindi': 'प्रगति का जश्न मनाएं',
        'tip': 'Acknowledge and celebrate each other\'s achievements and growth.',
        'hindiTip': 'एक-दूसरे की उपलब्धियों और विकास को स्वीकार करें और उनका जश्न मनाएं।',
      },
    ],
  };

  final Map<String, Map<String, dynamic>> _categoryInfo = {
    'communication': {
      'title': 'Communication',
      'hindi': 'संवाद',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
      'description': 'Effective communication tips',
    },
    'trust': {
      'title': 'Trust Building',
      'hindi': 'विश्वास निर्माण',
      'icon': Icons.handshake_outlined,
      'color': Colors.green,
      'description': 'Building and maintaining trust',
    },
    'romance': {
      'title': 'Romance',
      'hindi': 'रोमांस',
      'icon': Icons.favorite_outline,
      'color': Colors.pink,
      'description': 'Keeping the spark alive',
    },
    'conflict': {
      'title': 'Conflict Resolution',
      'hindi': 'संघर्ष समाधान',
      'icon': Icons.psychology_outlined,
      'color': Colors.orange,
      'description': 'Handling disagreements',
    },
    'intimacy': {
      'title': 'Intimacy',
      'hindi': 'अंतरंगता',
      'icon': Icons.favorite,
      'color': Colors.red,
      'description': 'Deepening your connection',
    },
    'growth': {
      'title': 'Growth Together',
      'hindi': 'एक साथ विकास',
      'icon': Icons.trending_up,
      'color': Colors.purple,
      'description': 'Growing as a couple',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relationship Tips 💕',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _categoryInfo.entries.map((entry) {
            final info = entry.value;
            return Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(info['icon'], size: 20),
                  const SizedBox(height: 4),
                  Text(
                    info['hindi'],
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade400,
              Colors.purple.shade300,
              Colors.indigo.shade300,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: _categoryInfo.keys.map((category) {
            return _buildTipsTab(category);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTipsTab(String category) {
    final categoryData = _categoryInfo[category]!;
    final tips = _relationshipTips[category]!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Category Header
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      categoryData['color'].shade100,
                      categoryData['color'].shade50,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      categoryData['icon'],
                      size: 40,
                      color: categoryData['color'],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${categoryData['title']} / ${categoryData['hindi']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: categoryData['color'].shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      categoryData['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: categoryData['color'].shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tips List
            Expanded(
              child: ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              categoryData['color'].shade50,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tip Title
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: categoryData['color'].shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: categoryData['color'].shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tip['title']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: categoryData['color'].shade700,
                                        ),
                                      ),
                                      Text(
                                        tip['hindi']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: categoryData['color'].shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // English Tip
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: categoryData['color'].shade200,
                                ),
                              ),
                              child: Text(
                                tip['tip']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Hindi Tip
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: categoryData['color'].shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: categoryData['color'].shade200,
                                ),
                              ),
                              child: Text(
                                tip['hindiTip']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
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
    );
  }
}