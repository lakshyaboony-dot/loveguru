import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isNewUser = false;
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_mobileController.text.length != 10) {
      _showSnackBar('कृपया वैध मोबाइल नंबर दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.instance.sendOTP(_mobileController.text);
      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        _showSnackBar('OTP भेजा गया है');
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('OTP भेजने में समस्या हुई');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('कुछ गलत हुआ है');
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    if (_otpController.text.length != 4) {
      _showSnackBar('कृपया 4 अंकों का OTP दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isOtpValid = await AuthService.instance.verifyOTP(
        _mobileController.text,
        _otpController.text,
      );

      if (isOtpValid) {
        // Check if user exists
        final existingUser = await AuthService.instance.getUserByMobile(_mobileController.text);
        
        if (existingUser == null) {
          // New user - show registration form
          setState(() {
            _isNewUser = true;
            _isLoading = false;
          });
        } else {
          // Existing user - login directly
          await AuthService.instance.loginUser(_mobileController.text, '');
          _navigateToDashboard();
        }
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('गलत OTP दर्ज किया गया');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('कुछ गलत हुआ है');
    }
  }

  Future<void> _registerUser() async {
    if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('कृपया सभी फील्ड भरें');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('पासवर्ड कम से कम 6 अक्षर का होना चाहिए');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.instance.registerUser(
        mobileNumber: _mobileController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (user != null) {
        _navigateToDashboard();
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('रजिस्ट्रेशन में समस्या हुई');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('कुछ गलत हुआ है');
    }
  }

  Future<void> _loginWithPassword() async {
    if (_mobileController.text.length != 10 || _passwordController.text.isEmpty) {
      _showSnackBar('कृपया मोबाइल नंबर और पासवर्ड दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.instance.loginUser(
        _mobileController.text,
        _passwordController.text,
      );

      if (user != null) {
        _navigateToDashboard();
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('गलत मोबाइल नंबर या पासवर्ड');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('कुछ गलत हुआ है');
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // App Logo/Title
                const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.pinkAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Love Guru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'आपका प्रेम सलाहकार',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Mobile Number Field
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !_isOtpSent,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'मोबाइल नंबर',
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone, color: Colors.pinkAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: const TextStyle(color: Colors.white70),
                    counterText: '',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // OTP Field (shown after OTP is sent)
                if (_isOtpSent && !_isNewUser) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'OTP दर्ज करें',
                      prefixIcon: const Icon(Icons.security, color: Colors.pinkAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],

                // Registration Fields (for new users)
                if (_isNewUser) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'आपका नाम',
                      prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'पासवर्ड बनाएं',
                      prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                ],

                // Password Field (for existing users)
                if (!_isOtpSent) ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'पासवर्ड (वैकल्पिक)',
                      prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                      helperText: 'पासवर्ड के बिना OTP से लॉगिन करें',
                      helperStyle: const TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _getButtonAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _getButtonText(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 16),

                // Alternative Action
                if (!_isOtpSent && _passwordController.text.isEmpty)
                  TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text(
                      'OTP से लॉगिन करें',
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  ),

                if (_isOtpSent && !_isNewUser)
                  TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text(
                      'OTP दोबारा भेजें',
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (_isNewUser) {
      return _registerUser;
    } else if (_isOtpSent) {
      return _verifyOtpAndLogin;
    } else if (_passwordController.text.isNotEmpty) {
      return _loginWithPassword;
    } else {
      return _sendOtp;
    }
  }

  String _getButtonText() {
    if (_isNewUser) {
      return 'रजिस्टर करें';
    } else if (_isOtpSent) {
      return 'OTP वेरिफाई करें';
    } else if (_passwordController.text.isNotEmpty) {
      return 'लॉगिन करें';
    } else {
      return 'OTP भेजें';
    }
  }
}