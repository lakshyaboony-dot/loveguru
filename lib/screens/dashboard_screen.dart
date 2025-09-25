import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';
import 'subscription_screen.dart';
import 'chat_screen.dart';
import 'compatibility_screen.dart';
import 'love_meter_screen.dart';
import 'relationship_tips_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _currentUser;
  SubscriptionModel? _currentSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.instance.getCurrentUser();
      final subscription = await SubscriptionService.instance.getCurrentSubscription();
      
      setState(() {
        _currentUser = user;
        _currentSubscription = subscription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading user data: $e');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('लॉगआउट'),
        content: const Text('क्या आप वाकई लॉगआउट करना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द करें'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हाँ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      await SubscriptionService.instance.clearSubscriptionData();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.pinkAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Love Guru Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              
              // Subscription Status Card
              _buildSubscriptionCard(),
              const SizedBox(height: 20),
              
              // Features Grid
              _buildFeaturesGrid(),
              const SizedBox(height: 20),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'नमस्ते!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _currentUser?.name ?? 'प्रिय उपयोगकर्ता',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'मोबाइल: ${_currentUser?.mobileNumber ?? 'N/A'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final isActive = _currentSubscription?.isActive ?? false;
    final planName = _currentSubscription?.planNameHindi ?? 'मुफ्त';
    final remainingDays = _currentSubscription?.remainingDays ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'सब्स्क्रिप्शन स्थिति',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'सक्रिय' : 'निष्क्रिय',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'वर्तमान प्लान: $planName',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            Text(
              'बचे हुए दिन: $remainingDays',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                ).then((_) => _loadUserData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isActive ? 'सब्स्क्रिप्शन प्रबंधित करें' : 'प्लान अपग्रेड करें',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'title': 'AI चैट',
        'subtitle': 'प्रेम सलाह पाएं',
        'icon': Icons.chat,
        'screen': const ChatScreen(),
        'available': true,
      },
      {
        'title': 'राशि मिलान',
        'subtitle': 'कम्पैटिबिलिटी चेक करें',
        'icon': Icons.favorite,
        'screen': const CompatibilityScreen(),
        'available': _currentSubscription?.isActive ?? false,
      },
      {
        'title': 'लव मीटर',
        'subtitle': 'प्रेम की मात्रा जानें',
        'icon': Icons.speed,
        'screen': const LoveMeterScreen(),
        'available': _currentSubscription?.isActive ?? false,
      },
      {
        'title': 'रिश्ते की सलाह',
        'subtitle': 'बेहतर रिश्ते के टिप्स',
        'icon': Icons.lightbulb,
        'screen': const RelationshipTipsScreen(),
        'available': _currentSubscription?.isActive ?? false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'फीचर्स',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            final isAvailable = feature['available'] as bool;
            
            return GestureDetector(
              onTap: () {
                if (isAvailable) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => feature['screen'] as Widget),
                  );
                } else {
                  _showUpgradeDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isAvailable ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAvailable ? Colors.pinkAccent : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 40,
                      color: isAvailable ? Colors.pinkAccent : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['subtitle'] as String,
                      style: TextStyle(
                        color: isAvailable ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.lock,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'त्वरित कार्य',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.pinkAccent),
          title: const Text('प्रोफाइल अपडेट करें', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          onTap: () {
            // Navigate to profile screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.pinkAccent),
          title: const Text('चैट हिस्ट्री', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          onTap: () {
            // Navigate to chat history
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.pinkAccent),
          title: const Text('सेटिंग्स', style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          onTap: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('प्रीमियम फीचर'),
        content: const Text('यह फीचर केवल प्रीमियम सदस्यों के लिए उपलब्ध है। कृपया अपना प्लान अपग्रेड करें।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('बाद में'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              ).then((_) => _loadUserData());
            },
            child: const Text('अपग्रेड करें'),
          ),
        ],
      ),
    );
  }
}