import 'package:flutter/material.dart';
import 'package:EcoMarket/Log_Page/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String> userData = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = {
        'email': prefs.getString('email') ?? '',
        'username': prefs.getString('username') ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B1B4D),
        title: Text(
          'ໂປຟາຍ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Top right gradient circle
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
          // Bottom left gradient circle
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
          // Main content
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: AssetImage('images/App_logo.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ຊື່ຜູ້ໃຊ້',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          '${userData['email'] ?? 'ບໍ່ມີ Email'} (${userData['username'] ?? 'ບໍ່ມີ Usename'})',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Card(
                color: const Color(0xFF23235B),
                margin: EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.blueAccent),
                        title: Text(
                          'ເບີໂທ:',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '20 97-471-681',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Divider(color: Colors.white24),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          'ທີ່ຢູ່:',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'ວຽງຈັນ, ລາວ',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout, color: Colors.indigo),
                  label: Text(
                    'ອອກຈາກລະບົບ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
