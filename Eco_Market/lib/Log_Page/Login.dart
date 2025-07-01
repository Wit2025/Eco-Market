import 'package:EcoMarket/Each_Menu/ForgotPassword.dart';
import 'package:EcoMarket/Log_Page/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/users/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ บันทึก role ลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', data['user']['role']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setString('username', data['user']['username']);
        final userId = int.tryParse(data['user']['id'].toString());
        if (userId != null) {
          await prefs.setInt('user_id', userId);
        } else {
          throw Exception('user_id ບໍ່ແມ່ນ int ຫຼື null');
        }

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: data['user'],
        );
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'ການເຂົ້າສູ່ລະບົບລົ້ມເຫຼວ';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ເກິດຂໍ້ຜິດພາດໃນການເຊື່ອມຕໍ່: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient Circle (Top Right)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent, Colors.deepPurple],
                  ),
                ),
              ),
            ),
            // Optional Second Gradient Circle (Bottom Left)
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Main Content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern Logo/Icon
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent,
                              Colors.purpleAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(18),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: const Color.fromARGB(255, 0, 32, 216),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        color: const Color(0xFF181846).withOpacity(
                          0.97,
                        ), // เปลี่ยนสีพื้นหลังฟอร์มให้เข้ากับพื้นหลัง
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                            vertical: 36,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'ຍິນດີຕ້ອນຮັບກັບມາ!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[100],
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Username
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'ຊື່ຜູ້ໃຊ້',
                                    labelStyle: TextStyle(
                                      color: Colors.deepPurple[100],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.deepPurple[200],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                    fillColor: Colors.deepPurple[900]
                                        ?.withOpacity(0.3),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 18,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'ກະລຸນາປ້ອນຊື່ຜູ້ໃຊ້';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'ລະຫັດຜ່ານ',
                                    labelStyle: TextStyle(
                                      color: Colors.deepPurple[100],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: Colors.deepPurple[200],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: Colors.deepPurple[200],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    filled: true,
                                    fillColor: Colors.deepPurple[900]
                                        ?.withOpacity(0.3),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 18,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'ລືມລະຫັດຜ່ານບໍ?',
                                      style: TextStyle(
                                        color: Colors.deepPurple[100],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_errorMessage != null) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.red[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'ເຂົ້າສູ່ລະບົບ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ຍັງບໍ່ມີບັນຊີແມ່ນບໍ?',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EmailVerificationPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'ສ້າງບັນຊີໃໝ່',
                                        style: TextStyle(
                                          color: Colors.purpleAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
