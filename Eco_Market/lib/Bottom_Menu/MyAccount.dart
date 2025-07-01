import 'package:EcoMarket/Each_Menu/Customers.dart';
import 'package:EcoMarket/Each_Menu/EmployeePage.dart';
import 'package:EcoMarket/Bottom_Menu/Help.dart';
import 'package:EcoMarket/Each_Menu/Monitor.dart';
import 'package:EcoMarket/Each_Menu/ProductsPage.dart';
import 'package:EcoMarket/Each_Menu/ReportPage.dart';
import 'package:EcoMarket/Each_Menu/SuplierPage.dart';
import 'package:flutter/material.dart';
import 'package:EcoMarket/Bottom_Menu/Notifications.dart';
import 'package:EcoMarket/Bottom_Menu/Profile.dart';
import 'package:EcoMarket/Log_Page/Login.dart';
import 'package:EcoMarket/Each_Menu/Category.dart';
import 'package:EcoMarket/Each_Menu/UnitPage.dart';
import 'package:EcoMarket/Each_Menu/Exchanges.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
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
        'role': prefs.getString('role') ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      body: Stack(
        children: [
          // Top right gradient circle
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
              // Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D0D2B), // เปลี่ยนเป็นโทนสีพื้นหลังนี้
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
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
                    const SizedBox(height: 16),
                    const Text(
                      'ຊື່ຜູ້ໃຊ້',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userData['email'] != null &&
                                    userData['email']!.isNotEmpty
                                ? '${userData['email']} (${userData['username'] ?? ''})'
                                : 'ບໍ່ມີອີເມວ',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  color: const Color(0xFF0D0D2B), // เปลี่ยนพื้นหลังส่วนนี้ด้วย
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        color: Colors.indigo,
                        title: 'ຂໍ້ມູນສ່ວນຕົວ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                      ),
                      if ((userData['role'] ?? '') != 'cashier') ...[
                        _buildMenuItem(
                          icon: Icons.shopping_cart,
                          color: Colors.indigo,
                          title: 'ສິນຄ້າ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.currency_exchange_outlined,
                          color: Colors.indigo,
                          title: 'ອັດຕາແລກປ່ຽນ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExchangeRateManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.rule,
                          color: Colors.indigo,
                          title: 'ຫົວໜ່ວຍສິນຄ້າ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnitManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.local_offer_outlined,
                          color: Colors.indigo,
                          title: 'ປະເພດສິນຄ້າ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.person_add,
                          color: Colors.indigo,
                          title: 'ພະນັກງານ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.group_add,
                          color: Colors.indigo,
                          title: 'ລູກຄ້າ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.local_shipping,
                          color: Colors.indigo,
                          title: 'ຜູ້ສະໜອງ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplierManagementPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.bar_chart,
                          color: Colors.indigo,
                          title: 'ລາຍງານການຂາາຍ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportManagePage(),
                              ),
                            );
                          },
                        ),
                      ],
                      if ((userData['role'] ?? '') == 'manager')
                        _buildMenuItem(
                          icon: Icons.monitor,
                          color: Colors.indigo,
                          title: 'Monitor',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Monitor(),
                              ),
                            );
                          },
                        ),
                      _buildMenuItem(
                        icon: Icons.notifications_none,
                        color: Colors.indigo,
                        title: 'ການແຈ້ງເຕື່ອນ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help,
                        color: Colors.indigo,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HelpPage()),
                          );
                        },
                      ),

                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        color: Colors.indigo,
                        title: 'ການຕັ້ງຄ່າ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 14,
                            ),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.indigo),
                          label: const Text(
                            'ອອກຈາກລະບົບ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: const Text('ການຕັ້ງຄ່າ'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: Color(0xFF0D0D2B),
        elevation: 0,
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
              decoration: const BoxDecoration(
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
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/App_logo.png'),
                      radius: 28,
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Text(
                        'ບັນຊີຂອງຂ້ອຍ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                color: Colors.indigo,
                title: 'Dark Mode',
                trailing: Switch(
                  value: false,
                  onChanged: (val) {},
                  activeColor: Colors.deepPurple,
                ),
              ),
              _buildSettingTile(
                icon: Icons.lock_outline,
                color: Colors.indigo,
                title: 'ປ່ຽນລະຫັດຜ່ານ',
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
              _buildSettingTile(
                icon: Icons.language_outlined,
                color: Colors.indigo,
                title: 'ພາສາ',
                trailing: const Text(
                  'ລາວ',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                color: Colors.indigo,
                title: 'ແຈ້ງເຕື່ອນ',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    elevation: 4,
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
                  icon: const Icon(Icons.logout, color: Colors.indigo),
                  label: const Text(
                    'ອອກຈາກລະບົບ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: trailing,
        onTap: () {},
      ),
    );
  }
}
