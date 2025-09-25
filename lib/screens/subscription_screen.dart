import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../models/subscription_model.dart';
import '../models/user_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionModel? _currentSubscription;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final subscription = await SubscriptionService.instance.getCurrentSubscription();
      final user = await AuthService.instance.getCurrentUser();
      
      setState(() {
        _currentSubscription = subscription;
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _subscribeToPlan(Map<String, dynamic> planData) async {
    if (_currentUser == null) return;

    setState(() => _isProcessing = true);

    try {
      // Show payment confirmation dialog
      final confirmed = await _showPaymentDialog(planData);
      
      if (confirmed == true) {
        // Create subscription
        final subscription = await SubscriptionService.instance.createSubscription(
          userId: _currentUser!.userId,
          plan: planData['plan'] as SubscriptionPlan,
          amount: planData['price'] as double,
          durationDays: planData['duration'] as int,
          paymentMethod: 'UPI', // This would come from actual payment gateway
          paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        );

        setState(() {
          _currentSubscription = subscription;
          _isProcessing = false;
        });

        _showSuccessDialog();
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog('सब्स्क्रिप्शन में समस्या हुई। कृपया दोबारा कोशिश करें।');
    }
  }

  Future<bool?> _showPaymentDialog(Map<String, dynamic> planData) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${planData['name']} खरीदें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('राशि: ₹${planData['price']}'),
            Text('अवधि: ${planData['duration']} दिन'),
            const SizedBox(height: 16),
            const Text('फीचर्स:'),
            ...((planData['features'] as List<String>).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• $feature'),
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'नोट: यह एक डेमो पेमेंट है। वास्तविक पेमेंट गेटवे एकीकृत नहीं है।',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('भुगतान करें'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('सफल!'),
        content: const Text('आपका सब्स्क्रिप्शन सफलतापूर्वक सक्रिय हो गया है।'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('त्रुटि'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('सब्स्क्रिप्शन रद्द करें'),
        content: const Text('क्या आप वाकई अपना सब्स्क्रिप्शन रद्द करना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('नहीं'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('हाँ, रद्द करें'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      
      final success = await SubscriptionService.instance.cancelSubscription();
      
      if (success) {
        await _loadData();
        _showSuccessDialog();
      } else {
        setState(() => _isProcessing = false);
        _showErrorDialog('सब्स्क्रिप्शन रद्द करने में समस्या हुई।');
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
          'सब्स्क्रिप्शन प्लान',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Subscription Status
            if (_currentSubscription != null) ...[
              _buildCurrentSubscriptionCard(),
              const SizedBox(height: 24),
            ],

            // Available Plans
            const Text(
              'उपलब्ध प्लान',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Plans List
            ..._buildPlansList(),

            const SizedBox(height: 24),

            // Features Comparison
            _buildFeaturesComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final subscription = _currentSubscription!;
    final isActive = subscription.isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive 
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'वर्तमान प्लान',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'सक्रिय' : 'समाप्त',
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
            subscription.planNameHindi,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isActive) ...[
            Text(
              'बचे हुए दिन: ${subscription.remainingDays}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              'समाप्ति तिथि: ${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _cancelSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('सब्स्क्रिप्शन रद्द करें'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPlansList() {
    final plans = SubscriptionService.instance.getSubscriptionPlans();
    
    return plans.map((planData) {
      final isCurrentPlan = _currentSubscription?.plan == planData['plan'];
      final isActive = _currentSubscription?.isActive ?? false;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPlan && isActive ? Colors.green : Colors.pinkAccent,
            width: isCurrentPlan && isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planData['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCurrentPlan && isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'वर्तमान',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '₹${planData['price']}',
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/${planData['duration']} दिन',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'फीचर्स:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...((planData['features'] as List<String>).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isCurrentPlan && isActive) || _isProcessing
                    ? null
                    : () => _subscribeToPlan(planData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        (isCurrentPlan && isActive) ? 'सक्रिय प्लान' : 'चुनें',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildFeaturesComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'फीचर्स तुलना',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureRow('दैनिक प्रश्न', ['3', '10', '50', 'असीमित']),
          _buildFeatureRow('वॉयस मैसेज', ['❌', '✅', '✅', '✅']),
          _buildFeatureRow('राशि मिलान', ['❌', '✅', '✅', '✅']),
          _buildFeatureRow('दैनिक राशिफल', ['❌', '❌', '✅', '✅']),
          _buildFeatureRow('रिश्ते की सलाह', ['❌', '❌', '✅', '✅']),
          _buildFeatureRow('प्राथमिकता सपोर्ट', ['❌', '❌', '❌', '✅']),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          ...values.map((value) => Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }
}