import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'all_users';
  static const String _otpKey = 'otp_data';
  
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  // Generate OTP
  String generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Save OTP for verification
  Future<bool> saveOTP(String mobileNumber, String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final otpData = {
        'mobile': mobileNumber,
        'otp': otp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      return await prefs.setString(_otpKey, jsonEncode(otpData));
    } catch (e) {
      print('Error saving OTP: $e');
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String mobileNumber, String enteredOTP) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final otpDataString = prefs.getString(_otpKey);
      
      if (otpDataString == null) return false;
      
      final otpData = jsonDecode(otpDataString);
      final savedMobile = otpData['mobile'];
      final savedOTP = otpData['otp'];
      final timestamp = otpData['timestamp'];
      
      // Check if OTP is expired (5 minutes)
      final now = DateTime.now().millisecondsSinceEpoch;
      final otpAge = now - timestamp;
      final fiveMinutes = 5 * 60 * 1000; // 5 minutes in milliseconds
      
      if (otpAge > fiveMinutes) {
        await prefs.remove(_otpKey);
        return false;
      }
      
      // Verify OTP and mobile number
      if (savedMobile == mobileNumber && savedOTP == enteredOTP) {
        await prefs.remove(_otpKey);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Register new user
  Future<UserModel?> registerUser({
    required String mobileNumber,
    required String password,
    String? name,
    String? email,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await getUserByMobile(mobileNumber);
      if (existingUser != null) {
        return null; // User already exists
      }

      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final hashedPassword = _hashPassword(password);
      
      final user = UserModel(
        userId: userId,
        mobileNumber: mobileNumber,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save user data
      final success = await _saveUser(user, hashedPassword);
      if (success) {
        await _setCurrentUser(user);
        return user;
      }
      
      return null;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Login user
  Future<UserModel?> loginUser(String mobileNumber, String password) async {
    try {
      final user = await getUserByMobile(mobileNumber);
      if (user == null) return null;

      final hashedPassword = _hashPassword(password);
      final savedPassword = await _getUserPassword(user.userId);
      
      if (savedPassword == hashedPassword) {
        // Update last login
        final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
        await _updateUser(updatedUser);
        await _setCurrentUser(updatedUser);
        return updatedUser;
      }
      
      return null;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  // Get current logged in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Set current user
  Future<bool> _setCurrentUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      return await prefs.setString(_currentUserKey, userJson);
    } catch (e) {
      print('Error setting current user: $e');
      return false;
    }
  }

  // Get user by mobile number
  Future<UserModel?> getUserByMobile(String mobileNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson != null) {
        final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
        
        for (final userData in usersData.values) {
          final user = UserModel.fromJson(userData['user']);
          if (user.mobileNumber == mobileNumber) {
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting user by mobile: $e');
      return null;
    }
  }

  // Save user data
  Future<bool> _saveUser(UserModel user, String hashedPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      
      usersData[user.userId] = {
        'user': user.toJson(),
        'password': hashedPassword,
      };
      
      return await prefs.setString(_usersKey, jsonEncode(usersData));
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Update user data
  Future<bool> _updateUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      
      if (usersData.containsKey(user.userId)) {
        usersData[user.userId]['user'] = user.toJson();
        await prefs.setString(_usersKey, jsonEncode(usersData));
        
        // Update current user if it's the same user
        final currentUser = await getCurrentUser();
        if (currentUser?.userId == user.userId) {
          await _setCurrentUser(user);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Get user password
  Future<String?> _getUserPassword(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      
      return usersData[userId]?['password'];
    } catch (e) {
      print('Error getting user password: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
      );
      
      return await _updateUser(updatedUser);
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      final oldHashedPassword = _hashPassword(oldPassword);
      final savedPassword = await _getUserPassword(currentUser.userId);
      
      if (savedPassword != oldHashedPassword) return false;
      
      final newHashedPassword = _hashPassword(newPassword);
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      
      usersData[currentUser.userId]['password'] = newHashedPassword;
      return await prefs.setString(_usersKey, jsonEncode(usersData));
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Send OTP (placeholder - integrate with SMS service)
  Future<bool> sendOTP(String mobileNumber) async {
    try {
      final otp = generateOTP();
      print('OTP for $mobileNumber: $otp'); // For testing - remove in production
      
      // Save OTP for verification
      await saveOTP(mobileNumber, otp);
      
      // Here you would integrate with SMS service like Twilio, MSG91, etc.
      // For now, just returning true
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Reset password with OTP
  Future<bool> resetPassword(String mobileNumber, String newPassword) async {
    try {
      final user = await getUserByMobile(mobileNumber);
      if (user == null) return false;
      
      final newHashedPassword = _hashPassword(newPassword);
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final usersData = jsonDecode(usersJson) as Map<String, dynamic>;
      
      usersData[user.userId]['password'] = newHashedPassword;
      return await prefs.setString(_usersKey, jsonEncode(usersData));
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }
}