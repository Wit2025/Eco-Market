import 'package:EcoMarket/Each_Menu/ProductsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Map<String, String> userData = {};
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = {'role': prefs.getString('role') ?? ''};
    });
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/products/products/chechk_stock',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          notifications = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData _getIcon() {
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Text('ການແຈ້ງເຕືອນ'),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: const Color(0xFF1B1B4D),
        elevation: 4,
      ),
      body: Stack(
        children: [
          // background gradient
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
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                )
              : notifications.isEmpty
              ? Center(
                  child: Text(
                    'ບໍ່ມີການແຈ້ງເຕືອນ',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Card(
                      color: const Color(0xFF23235B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purpleAccent,
                          child: Icon(_getIcon(), color: Colors.redAccent),
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ສິນຄ້າທີ່ຍັງເຫຼືອໜ້ອຍ ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: '${item['name']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          'ລະຫັດ: ${item['product_id']} \nຈຳນວນຍັງເຫຼືອ: ${item['stock_quantity']}',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing:
                            (userData.isNotEmpty &&
                                userData['role'] == 'cashier')
                            ? null
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                        onTap:
                            (userData.isNotEmpty &&
                                userData['role'] == 'cashier')
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductManagementPage(
                                      productId: item['product_id'],
                                    ),
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
