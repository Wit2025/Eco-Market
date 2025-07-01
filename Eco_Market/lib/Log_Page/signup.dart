import 'package:EcoMarket/Log_Page/Login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ລະບົບສະໝັກສະມາຊິກ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.indigo.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const EmailVerificationPage(),
    );
  }
}

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _employeeData;

  Future<void> _checkEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/employees/employees/search/email/${_emailController.text.trim()}',
        ),
      );

      if (response.statusCode == 200) {
        final employees = json.decode(response.body) as List;

        if (employees.isEmpty) {
          setState(() {
            _errorMessage = 'ອີເມລນີ້ບໍ່ໄດ້ເປັນພະນັກງານຂອງພວກເຮົາ';
          });
        } else {
          final employee = employees[0];

          final userCheck = await http.get(
            Uri.parse(
              'http://192.168.17.133:3001/api/users/users/employee/${employee['employee_id']}',
            ),
          );

          if (userCheck.statusCode == 200) {
            final users = json.decode(userCheck.body) as List;

            if (users.isNotEmpty) {
              setState(() {
                _errorMessage = 'ອີເມລນີ້ມີຊື່ຜູ້ໃຊ້ແລ້ວ';
              });
            } else {
              setState(() {
                _employeeData = employee;
              });
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ເກີດຂໍ້ຜິດພາດໃນການກວດສອບອີເມລ: $e';
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
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              'ລະບົບສະໝັກສະມາຊິກ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B1B4D),
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Background Gradient Circle (top right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurple],
                ),
              ),
            ),
          ),
          // Optional Second Gradient Circle (bottom left)
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _employeeData == null
                    ? _buildEmailForm()
                    : SignupForm(employeeData: _employeeData!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Card(
      elevation: 12,
      color: Color(0xFF0D0D2B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      shadowColor: Colors.indigo.withOpacity(0.7),
      margin: const EdgeInsets.fromLTRB(24, 64, 24, 32), // Increased top margin
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email, color: Colors.indigo, size: 60),
              const SizedBox(height: 12),
              const Text(
                'ກວດສອບອີເມລ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ອີເມລ',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'ປ້ອນອີເມລທີ່ລົງທະບຽນກັບຮ້ານ',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.alternate_email, color: Colors.white),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ກະລຸນາປ້ອນອີເມລ';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'ກະລຸນາປ້ອນອີເມລທີ່ຖືກຕ້ອງ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ກວດສອບອີເມລ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0D0D2B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _checkEmail,
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  const SignupForm({Key? key, required this.employeeData}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'ລະຫັດຜ່ານບໍ່ຄືກັນ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/users/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': widget.employeeData['employee_id'],
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _successMessage = 'ສະໝັກສະມາຊິກສໍາເລັດ';
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ສະໝັກສະມາຊິກສໍາເລັດ'),
            content: const Text('ທ່ານສາມາດເຂົ້າສູ່ລະບົບໄດ້ແລ້ວ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text('ຕົກລົງ'),
              ),
            ],
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'ເກີດຂໍ້ຜິດພາດໃນການສະໝັກສະມາຊິກ';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ເກີດຂໍ້ຜິດພາດໃນການເຊື່ອມຕໍ່ກັບເຊີບເວີ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0D0D2B),
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.indigo.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_add_alt_1,
                color: Colors.indigo,
                size: 60,
              ),
              const SizedBox(height: 12),
              const Text(
                'ສະໝັກສະມາຊິກ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ລະຫັດສະມາຊິກ: ${widget.employeeData['employee_id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ຊື່: ${widget.employeeData['name']} ${widget.employeeData['lastname']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'ອີເມລ: ${widget.employeeData['email']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ຊື່ຜູ້ໃຊ້',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'ປ້ອນຊື່ຜູ້ໃຊ້ທີ່ທ່ານຈະໃຊ້',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ກະລຸນາປ້ອນຊື່ຜູ້ໃຊ້';
                  }
                  if (value.length < 4) {
                    return 'ຊື່ຜູ້ໃຊ້ຕ້ອງຍາວຢ່າງໜ້ອຍ 4 ໂຕອັກສອນ';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'ຊື່ຜູ້ໃຊ້ສາມາດໃຊ້ໄດ້ໂຕອັກສອນ a-z, 0-9 ແລະ _';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'ລະຫັດຜ່ານ',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'ປ້ອນລະຫັດຜ່ານຢ່າງໜ້ອຍ 6 ໂຕອັກສອນ',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
                  }
                  if (value.length < 6) {
                    return 'ລະຫັດຜ່ານຕ້ອງມີຄວາມຍາວ 6 ໂຕອັກສອນຂຶ້ນໄປ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'ຢືນຢັນລະຫັດຜ່ານ',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'ປ້ອນລະຫັດຜ່ານອີກຄັ້ງ',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ກະລຸນາປ້ອນລະຫັດຢືນຢັນ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text(
                      'ສະໝັກສະມາຊິກ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 0, 92),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitForm,
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'ກັບໄປ',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _successMessage = null;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmailVerificationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
