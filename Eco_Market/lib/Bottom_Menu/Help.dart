import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຊ່ວຍເຫຼືອ',
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
              decoration: BoxDecoration(
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 32),
                    Icon(
                      Icons.help_outline,
                      size: 80,
                      color: Colors.purpleAccent,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'ຊ່ວຍເຫຼືອ & ຖາມຄຳຖາມ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Card(
                      color: const Color(0xFF23235B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.info,
                                color: Colors.purpleAccent,
                              ),
                              title: Text(
                                'ວິທີໃຊ້ແອັບ',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'ຄຳແນະນຳການໃຊ້ງານແອັບພິເຄຊັນ',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Divider(color: Colors.white24),
                            ListTile(
                              leading: Icon(
                                Icons.contact_support,
                                color: Colors.blueAccent,
                              ),
                              title: Text(
                                'ຕິດຕໍ່ສະໜັບສະໜຸນ',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'ຕິດຕໍ່ພວກເຮົາຜ່ານອີເມວ: support@example.com',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Divider(color: Colors.white24),
                            ListTile(
                              leading: Icon(
                                Icons.security,
                                color: Colors.orangeAccent,
                              ),
                              title: Text(
                                'ຄວາມປອດໄພ',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'ຂໍ້ມູນຂອງທ່ານຖືກປົກປ້ອງຢ່າງດີ',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      'ຂອບໃຈທີ່ໃຊ້ບໍລິການຂອງພວກເຮົາ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
