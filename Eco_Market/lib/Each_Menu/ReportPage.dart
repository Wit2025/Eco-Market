import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportManagePage extends StatefulWidget {
  @override
  _ReportManagePageState createState() => _ReportManagePageState();
}

class _ReportManagePageState extends State<ReportManagePage> {
  String _selectedReport = 'sales-report';
  String _selectedPeriod = 'day';
  List<dynamic> _reportData = [];
  bool _isLoading = false;

  final Map<String, String> _reportTitles = {
    'sales-report': 'ຍອດການຂາຍ',
    'best-selling-products': 'ສິນຄ້າທີ່ຂາຍດີທີ່ສຸດ',
    'worst-selling-products': 'ສິນຄ້າທີ່ຂາຍໄດ້ນ້ອຍທີ່ສຸດ',
    'unsold-products': 'ສິນຄ້າທີ່ບໍ່ໄດ້ຂາຍ',
    'top-employees': 'ພະນັກງານທີ່ມີຍອດຂາຍຫຼາຍທີ່ສຸດ',
  };

  final Color _primaryColor = Color(0xFF2C3E50);
  final Color _accentColor = Color(0xFF00B894);
  final Color _cardColor = Color(0xFF0D0D2B);

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _reportData = [];
    });

    try {
      final url = Uri.parse(
        'http://192.168.17.133:3001/api/reports/${_selectedReport}?period=${_selectedPeriod}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _reportData = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReportWidget() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _accentColor));
    }

    if (_reportData.isEmpty) {
      return Center(
        child: Text(
          'ບໍ່ມີຂໍ້ມູນ',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    switch (_selectedReport) {
      case 'sales-report':
        return _buildSalesReport();
      case 'best-selling-products':
      case 'worst-selling-products':
        return _buildProductReport();
      case 'unsold-products':
        return _buildUnsoldProducts();
      case 'top-employees':
        return _buildTopEmployees();
      default:
        return Center(child: Text('ບໍ່ຮູ້ຈັກປະເພດການລາຍງານ'));
    }
  }

  Widget _buildSalesReport() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final item = _reportData[index];
        return Card(
          color: _cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _accentColor,
              child: Icon(Icons.bar_chart, color: Colors.white),
            ),
            title: Text(
              'ຍອດຂາຍຂອງວັນທີ ${item['date'].toString().split('T')[0]}',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ຈຳນວນທີ່ໄດ້ຂາຍ: ${item['total_orders']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Text(
              'ລວມເປັນເງິນ ${item['total_sales'].toStringAsFixed(2)} ກີບ',
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductReport() {
    // กำหนดสีตามประเภทของรายงาน
    Color avatarColor;
    Color trailingColor;
    IconData iconData;

    if (_selectedReport == 'best-selling-products') {
      avatarColor = Colors.green;
      trailingColor = Colors.green;
      iconData = Icons.trending_up;
    } else if (_selectedReport == 'worst-selling-products') {
      avatarColor = Colors.orange;
      trailingColor = Colors.orange;
      iconData = Icons.trending_down;
    } else {
      avatarColor = _accentColor;
      trailingColor = _accentColor;
      iconData = Icons.shopping_bag;
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final product = _reportData[index];
        return Card(
          color: _cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: Icon(iconData, color: Colors.white),
            ),
            title: Text(
              product['name'],
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ຈຳນວນທີ່ໄດ້ຂາຍ: ${product['total_quantity']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Text(
              'ລວມເປັນເງິນ ${product['total_sales'].toStringAsFixed(2)} ກີບ',
              style: TextStyle(
                color: trailingColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnsoldProducts() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final product = _reportData[index];
        return Card(
          color: _cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.remove_shopping_cart, color: Colors.white),
            ),
            title: Text(
              product['name'],
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ລະຫັດສິນຄ້າ: ${product['product_id']}',
              style: TextStyle(color: Colors.black),
            ),
            trailing: Text(
              'ລາຄາ/ອັນ ${product['price'].toStringAsFixed(2)} ກີບ',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopEmployees() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final employee = _reportData[index];
        return Card(
          color: _cardColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _accentColor,
              child: Text(
                (employee['employee_name'] != null &&
                        employee['employee_last_name'] != null)
                    ? employee['employee_name'][0] +
                          employee['employee_last_name'][0]
                    : '',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${employee['employee_name'] ?? ''} ${employee['employee_last_name'] ?? ''}',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ຈຳນວນທີ່ໄດ້ຂາຍ: ${employee['total_orders']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Text(
              'ລວມເປັນເງິນ ${(employee['total_sales'] is num ? employee['total_sales'] : double.tryParse(employee['total_sales'].toString()) ?? 0).toStringAsFixed(2)} ກີບ',
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B4D),
        elevation: 4,
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ລາຍງານການຂາຍສິນຄ້າ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'ໂຫຼດໃໝ່',
            onPressed: _fetchReport,
          ),
        ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF23235B),
                        value: _selectedReport,
                        items: _reportTitles.keys.map((key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Text(
                              _reportTitles[key]!,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReport = value!;
                          });
                          _fetchReport();
                        },
                        decoration: InputDecoration(
                          labelText: 'ປະເພດລາຍງານ',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF23235B),
                        value: _selectedPeriod,
                        items: ['day', 'month', 'year'].map((period) {
                          String periodName;
                          switch (period) {
                            case 'day':
                              periodName = 'ປະຈຳວັນ';
                              break;
                            case 'month':
                              periodName = 'ປະຈຳເດືອນ';
                              break;
                            case 'year':
                              periodName = 'ປະຈຳປີ';
                              break;
                            default:
                              periodName = period;
                          }
                          return DropdownMenuItem(
                            value: period,
                            child: Text(
                              periodName,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                          _fetchReport();
                        },
                        decoration: InputDecoration(
                          labelText: 'ໄລຍະເວລາ',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'ລາຍງານ${_reportTitles[_selectedReport] ?? 'ບໍ່ຮູ້ຈັກ'}ໃນ${_selectedPeriod == 'day'
                        ? 'ມື້ນີ້'
                        : _selectedPeriod == 'month'
                        ? 'ເດືອນນີ້'
                        : 'ປີນີ້'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: const Color(0xFF23235B),
                      textTheme: Theme.of(context).textTheme.apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                    ),
                    child: _buildReportWidget(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }
}
