import 'package:EcoMarket/Each_Menu/im.dart';
import 'package:flutter/material.dart';
import 'package:EcoMarket/Bottom_Menu/MyAccount.dart';
import 'package:EcoMarket/Bottom_Menu/Notifications.dart';
import 'package:EcoMarket/Bottom_Menu/Help.dart';
import 'package:EcoMarket/Log_Page/Login.dart';
import 'package:EcoMarket/Home_Page/FirstPages.dart';
import 'package:EcoMarket/Each_Menu/Category.dart';
import 'package:EcoMarket/Each_Menu/Customers.dart';
import 'package:EcoMarket/Each_Menu/EmployeePage.dart';
import 'package:EcoMarket/Each_Menu/Monitor.dart';
import 'package:EcoMarket/Each_Menu/Orders.dart';
import 'package:EcoMarket/Each_Menu/ProductsPage.dart';
import 'package:EcoMarket/Each_Menu/ReportPage.dart';
import 'package:EcoMarket/Each_Menu/SuplierPage.dart';
import 'package:EcoMarket/Each_Menu/UnitPage.dart';
import 'package:EcoMarket/Each_Menu/Exchanges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  String? _userRole;
  int stockLowCount = 0;

  @override
  void initState() {
    super.initState();
    _userRole = widget.userData['role']?.toLowerCase();
    _currentIndex = 1;
    fetchLowStockCount();
  }

  List<Widget> get _bottomNavPages {
    if (_userRole == 'cashier') {
      return [
        OrderManagementPage(), // index 0 = ขายสินค้า
        FirstPages(), // index 1 = หน้าแรก (อยู่ตรงกลาง)
        MyAccount(), // index 2 = ของข้ອຍ
      ];
    }

    return [EmployeeManagementPage(), FirstPages(), MyAccount()];
  }

  // Get bottom navigation items based on user role
  List<BottomNavigationBarItem> get _bottomNavItems {
    if (_userRole == 'cashier') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'ຂາຍສິນຄ້າ',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ໜ້າຫຼັກ'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box_outlined),
          label: 'ຂອງຂ້ອຍ',
        ),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.people), label: 'ພະນັກງານ'),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ໜ້າຫຼັກ'),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box_outlined),
        label: 'ຂອງຂ້ອຍ',
      ),
    ];
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    final ThemeMode newThemeMode = _isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
    final appContext = context.findAncestorStateOfType<_MyAppState>();
    if (appContext != null) {
      appContext.changeTheme(newThemeMode);
    }
  }

  Future<void> fetchLowStockCount() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/products/products/chechk_stock',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stockLowCount = data.length;
        });
      }
    } catch (e) {
      print("Error fetching low stock count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D2B),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('ໜ້າຫຼັກ'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          Row(
            children: [
              Text(
                widget.userData['role'] ?? 'ບໍ່ມີບົດບາດ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      ).then((_) {
                        // รีโหลดจำนวนใหม่เมื่อกลับมา
                        fetchLowStockCount();
                      });
                    },
                  ),
                  if (stockLowCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 13,
                          minHeight: 13,
                        ),
                        child: Center(
                          child: Text(
                            '$stockLowCount',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    widget.userData['username'] ?? 'ບໍ່ມີ Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    widget.userData['email'] ?? 'ບໍ່ມີ Email',
                    style: TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('images/App_logo.png'),
                    radius: 30,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: _userRole == 'cashier'
                            ? Icons.shopping_cart
                            : Icons.shopping_cart_checkout_outlined,
                        title: _userRole == 'cashier'
                            ? 'ຂາຍສິນຄ້າ'
                            : 'ປະຫວັດການຂາຍ',
                        onTap: () => _navigateTo(
                          context,
                          _userRole == 'cashier'
                              ? OrderManagementPage()
                              : OrderManagementPage(),
                        ),
                      ),
                      Divider(color: Colors.white70),
                      if (_userRole != 'cashier') ...[
                        _buildDrawerItem(
                          icon: Icons.person,
                          title: 'ພະນັກງານ',
                          onTap: () =>
                              _navigateTo(context, EmployeeManagementPage()),
                        ),
                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons.local_shipping,
                          title: 'ຜູ້ສະໜອງ',
                          onTap: () =>
                              _navigateTo(context, SupplierManagementPage()),
                        ),
                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons.local_offer,
                          title: 'ປະເພດສິນຄ້າ',
                          onTap: () =>
                              _navigateTo(context, CategoryManagementPage()),
                        ),
                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons
                              .bar_chart, // ใช้ไอคอน bar_chart สำหรับรายงาน
                          title: 'ລາຍງານການຂາຍ',
                          onTap: () => _navigateTo(context, ReportManagePage()),
                        ),
                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons.rule_sharp,
                          title: 'ຫົວໜ່ວຍສິນຄ້າ',
                          onTap: () =>
                              _navigateTo(context, UnitManagementPage()),
                        ),

                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons.shopping_cart,
                          title: 'ສິນຄ້າ',
                          onTap: () =>
                              _navigateTo(context, ProductManagementPage()),
                        ),
                        Divider(color: Colors.white70),
                        _buildDrawerItem(
                          icon: Icons.currency_exchange,
                          title: 'ອັດຕາແລກປ່ຽນ',
                          onTap: () => _navigateTo(
                            context,
                            ExchangeRateManagementPage(),
                          ),
                        ),
                      ],
                      _buildDrawerItem(
                        icon: Icons.person_add,
                        title: 'ລູກຄ້າ',
                        onTap: () =>
                            _navigateTo(context, CustomerManagementPage()),
                      ),
                      Divider(color: Colors.white70),
                      if (_userRole == 'manager') ...[
                        _buildDrawerItem(
                          icon: Icons.monitor,
                          title: 'Monitor',
                          onTap: () => _navigateTo(context, Monitor()),
                        ),
                        Divider(color: Colors.white70),
                      ],
                      _buildDrawerItem(
                        icon: Icons.help,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () => _navigateTo(context, HelpPage()),
                      ),
                      Divider(color: Colors.white70),
                      _buildDrawerItem(
                        icon: Icons.image,
                        title: 'ເພີ່ມຮູບ',
                        onTap: () => _navigateTo(context, UploadImagePage()),
                      ),
                      Divider(color: Colors.white70),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'ອອກຈາກລະບົບ',
                        iconColor: Colors.redAccent,
                        onTap: () async {
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
                      ),
                      Divider(color: Colors.white70),
                      ListTile(
                        leading: Icon(Icons.brightness_6, color: Colors.white),
                        title: Text(
                          _isDarkMode ? 'ແຈ້ງ' : 'ມືດ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (bool value) {
                            _toggleTheme();
                          },
                          activeColor: Colors.deepPurpleAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _bottomNavPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF0D0D2B),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Market',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: LoginPage(),
      routes: {'/login': (context) => LoginPage()},
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomePage(userData: args),
          );
        }
        return MaterialPageRoute(
          builder: (context) =>
              Scaffold(body: Center(child: Text('ບໍ່ພົບໜ້າທີ່ຕ້ອງການ'))),
        );
      },
    );
  }
}
