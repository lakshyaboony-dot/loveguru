import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/usage_limit_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _usageStatus = {};

  @override
  void initState() {
    super.initState();
    _loadUsageStatus();
  }

  Future<void> _loadUsageStatus() async {
    final status = await UsageLimitService.getUsageStatus();
    setState(() {
      _usageStatus = status;
    });
  }

  Future<void> _processPayment(String type, double amount, {int? months, int? chats, int? predictions}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, integrate with UPI payment gateway here
      final success = await _showUPIPayment(amount);
      
      if (success) {
        if (type == 'subscription' && months != null) {
          await UsageLimitService.activatePremium(months);
        } else if (type == 'topup' && chats != null && predictions != null) {
          await UsageLimitService.addTopupCredits(chats, predictions);
        }
        
        await _loadUsageStatus();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showUPIPayment(double amount) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UPI Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: ₹${amount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('Choose payment method:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUPIButton('GPay', 'assets/gpay.png'),
                _buildUPIButton('PhonePe', 'assets/phonepe.png'),
                _buildUPIButton('Paytm', 'assets/paytm.png'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'UPI ID: loveguru@upi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'loveguru@upi'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID copied!')),
                );
              },
              child: const Text('Copy UPI ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Payment Done'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildUPIButton(String name, String assetPath) {
    return GestureDetector(
      onTap: () {
        // In a real app, launch the respective UPI app
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $name...')),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium Plans 💎',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade400, Colors.pink.shade300],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Usage Status Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Current Usage',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUsageItem(
                            'Chats Left',
                            '${_usageStatus['remainingChats'] ?? 0}',
                            Icons.chat,
                          ),
                          _buildUsageItem(
                            'Predictions Left',
                            '${_usageStatus['remainingPredictions'] ?? 0}',
                            Icons.favorite,
                          ),
                        ],
                      ),
                      if (_usageStatus['isPremium'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '👑 PREMIUM ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Subscription Plans
              const Text(
                'Subscription Plans',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPlanCard(
                'Monthly Premium',
                '₹99',
                'per month',
                [
                  'Unlimited Chats',
                  'Unlimited Predictions',
                  'Priority Support',
                  'Ad-free Experience',
                ],
                () => _processPayment('subscription', 99, months: 1),
                Colors.blue,
              ),
              
              const SizedBox(height: 16),
              
              _buildPlanCard(
                'Yearly Premium',
                '₹699',
                'per year (Save ₹489!)',
                [
                  'Unlimited Chats',
                  'Unlimited Predictions',
                  'Priority Support',
                  'Ad-free Experience',
                  'Exclusive Features',
                ],
                () => _processPayment('subscription', 699, months: 12),
                Colors.green,
                isPopular: true,
              ),
              
              const SizedBox(height: 24),
              
              // Topup Option
              const Text(
                'Quick Topup',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPlanCard(
                'Instant Topup',
                '₹10',
                'one-time',
                [
                  '10 Extra Chats',
                  '2 Extra Predictions',
                  'Valid for today',
                ],
                () => _processPayment('topup', 10, chats: 10, predictions: 2),
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageItem(String title, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.purple),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String period,
    List<String> features,
    VoidCallback onTap,
    Color color, {
    bool isPopular = false,
  }) {
    return Stack(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isPopular ? Border.all(color: Colors.amber, width: 3) : null,
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(feature),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Choose Plan',
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
        if (isPopular)
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}