import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_provider.dart';
import '../services/ai_response_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_button.dart';
import 'love_meter_screen.dart';
import 'compatibility_screen.dart';
import 'date_of_birth_screen.dart';
import 'relationship_tips_screen.dart';
import 'dashboard_screen.dart';
import '../screens/payment_screen.dart';
import '../services/usage_limit_service.dart';
import '../services/music_service.dart';
import '../services/subscription_service.dart';
import 'subscription_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UsageLimitService _usageService = UsageLimitService();
  final SubscriptionService _subscriptionService = SubscriptionService.instance;
  int _remainingChats = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  void _loadUsageData() async {
    final remaining = await _usageService.getRemainingChats();
    setState(() {
      _remainingChats = remaining;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Check subscription
    final hasActiveSubscription =
        await _subscriptionService.hasActiveSubscription();

    if (!hasActiveSubscription) {
      // Check usage limit
      if (!await _usageService.canUseChat()) {
        _showUsageLimitDialog();
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);

    // Add user message
    chatProvider.addMessage(message, true);
    _messageController.clear();

    _scrollToBottom();

    // Typing indicator
    chatProvider.setTyping(true);

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // ✅ FIXED: Await AI response
    final aiResponse = await AIResponseService.generateResponse(message);

    chatProvider.setTyping(false);
    chatProvider.addMessage(aiResponse, false);

    if (!hasActiveSubscription) {
      await _usageService.incrementChatUsage();
      _loadUsageData();
    }

    // ✅ FIXED: Await voice
    await voiceProvider.speak(aiResponse);

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _showUsageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text(
            'You have reached your daily chat limit of 10 messages. Upgrade to premium for unlimited chats or wait until tomorrow.'),
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
                MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen()),
              );
            },
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Love Guru - प्रेम गुरु',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 2,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE4EC),
              Color(0xFFF8BBD9),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildWelcomeCard(context),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chatProvider.messages.length +
                        (chatProvider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatProvider.messages.length &&
                          chatProvider.isTyping) {
                        return const MessageBubble(
                          message: 'टाइप कर रहा है...',
                          isUser: false,
                          isTyping: true,
                        );
                      }

                      final message = chatProvider.messages[index];
                      return MessageBubble(
                        message: message.text,
                        isUser: message.isUser,
                        timestamp: message.timestamp,
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 32),
              const SizedBox(height: 8),
              Text(
                'नमस्ते! मैं आपका Love Guru हूँ 💕',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'प्यार और रिश्तों के बारे में कुछ भी पूछें',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const VoiceButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<VoiceProvider>(
                builder: (context, voiceProvider, child) {
                  if (voiceProvider.recognizedText.isNotEmpty &&
                      _messageController.text != voiceProvider.recognizedText) {
                    _messageController.text = voiceProvider.recognizedText;
                    _messageController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _messageController.text.length),
                    );
                  }

                  return TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: voiceProvider.isListening
                          ? 'सुन रहा हूँ...'
                          : 'अपना सवाल लिखें...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            const BorderSide(color: Color(0xFFE91E63)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Color(0xFFE91E63), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) => _sendMessage(text),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: () => _sendMessage(_messageController.text),
              backgroundColor: const Color(0xFFE91E63),
              mini: true,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFAD1457)]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Love Guru Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.chat,
              title: 'Chat with Guru',
              subtitle: 'गुरु से बात करें',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              subtitle: 'डैशबोर्ड',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite_border,
              title: 'Love Meter',
              subtitle: 'प्रेम मीटर',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoveMeterScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.stars,
              title: 'Compatibility',
              subtitle: 'संगतता जांच',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CompatibilityScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'Love Predictions',
              subtitle: 'जन्म तिथि आधारित प्रेम भविष्यवाणी',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DateOfBirthScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.tips_and_updates,
              title: 'Relationship Tips',
              subtitle: 'रिश्ते की सलाह',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RelationshipTipsScreen()),
                );
              },
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Usage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Chats remaining: $_remainingChats/10'),
                  const SizedBox(height: 4),
                  FutureBuilder<int>(
                    future: _usageService.getRemainingPredictions(),
                    builder: (context, snapshot) {
                      return Text(
                          'Predictions remaining: ${snapshot.data ?? 1}/1');
                    },
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.payment,
              title: 'Premium Plans',
              subtitle: 'प्रीमियम योजनाएं',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentScreen()),
                );
              },
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Background Music',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.pink[700],
                    ),
                  ),
                  Switch(
                    value: !MusicService().isMuted,
                    onChanged: (value) {
                      setState(() {
                        MusicService().toggleMute();
                      });
                    },
                    activeColor: Colors.pink[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
