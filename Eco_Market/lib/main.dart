import 'package:EcoMarket/Home_Page/Home.dart';
import 'package:EcoMarket/Log_Page/Login.dart';
import 'package:flutter/material.dart';
// นำเข้าไฟล์อื่นๆ ตามที่จำเป็น

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Market',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        // ไม่ต้องกำหนด '/home' ที่นี่เพราะเราจะใช้ onGenerateRoute
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          // รับข้อมูลที่ส่งมา
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;

          // ส่งข้อมูลไปยังหน้า HomePage
          return MaterialPageRoute(
            builder: (context) => HomePage(userData: args),
          );
        }
        // กรณีไม่พบเส้นทาง
        return MaterialPageRoute(
          builder: (context) =>
              Scaffold(body: Center(child: Text('ບໍ່ພົບໜ້າທີ່ຕ້ອງການ'))),
        );
      },
    );
  }
}
