import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Order {
  final int orderId;
  final int? customerId;
  final int? userId;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customerName;
  final String? employeeName;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    this.customerId,
    this.userId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.employeeName,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final itemsList = itemsJson.map((e) => OrderItem.fromJson(e)).toList();

    return Order(
      orderId: json['order_id'] as int? ?? 0,
      customerId: json['customer_id'] as int?,
      userId: json['user_id'] as int?,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: _parseLocalTime(json['created_at']),
      updatedAt: _parseLocalTime(json['updated_at']),
      customerName: json['customer_name'] as String?,
      employeeName: json['employee_name'] as String?,
      items: itemsList,
    );
  }

  static DateTime _parseLocalTime(dynamic time) {
    if (time == null) return DateTime.now();

    final dateString = time.toString();

    try {
      if (!dateString.endsWith('Z') && !dateString.contains('+')) {
        return DateTime.parse('${dateString.replaceAll(' ', 'T')}+07:00');
      }
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      print('Error parsing date: $dateString. Error: $e');
      return DateTime.now();
    }
  }

  String get formattedCreatedAt {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(createdAt);
  }

  String get formattedUpdatedAt {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(updatedAt);
  }
}

class OrderItem {
  final int itemId;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    this.itemId = 0,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}

class Bill {
  final int? id;
  final int? orderId;
  final double amountMoney;
  final double amountChange;
  final int? currencyId;
  final double? exchangeRate;
  final String? currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    this.id,
    this.orderId,
    required this.amountMoney,
    required this.amountChange,
    this.currencyId,
    this.exchangeRate,
    this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      orderId: json['orderId'] != null
          ? int.tryParse(json['orderId'].toString())
          : null,
      amountMoney: (json['amountMoney'] as num?)?.toDouble() ?? 0.0,
      amountChange: (json['amountChange'] as num?)?.toDouble() ?? 0.0,
      currencyId: json['currencyId'] != null
          ? int.tryParse(json['currencyId'].toString())
          : null,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
    );
  }
}

class Product {
  final int productId;
  final String name;
  final double price;
  final double stockQuantity;
  final String? barcode; // <- เพิ่มตรงนี้

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      stockQuantity: double.parse(json['stock_quantity'].toString()),
      barcode: json['barcode'] != null ? json['barcode'] as String : null,
    );
  }
}

class Customer {
  final int customerId;
  final String name;

  Customer({required this.customerId, required this.name});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(customerId: json['customer_id'], name: json['name']);
  }
}

class Employee {
  final int employeeId;
  final String name;

  Employee({required this.employeeId, required this.name});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(employeeId: json['employee_id'], name: json['name']);
  }
}

class ExchangeRate {
  final int id;
  final String currencyCode;
  final double rate;
  final String unit;

  ExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.rate,
    required this.unit,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      id: json['id'],
      currencyCode: json['currency_code'],
      rate: double.parse(json['rate'].toString()),
      unit: json['unit'] ?? 'LAK',
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeRate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode => id.hashCode ^ currencyCode.hashCode;
}

class OrderManagementPage extends StatefulWidget {
  final int? initialOrderIdToShowBill;

  OrderManagementPage({this.initialOrderIdToShowBill});
  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  List<Order> orders = [];
  List<Order> orderItems = [];
  List<Order> filteredOrders = [];
  List<Product> products = [];
  List<Customer> customers = [];
  List<Employee> employees = [];
  List<ExchangeRate> exchangeRates = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  List<OrderItem> _tempItems = [];

  // Form controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();
  final TextEditingController totalPriceOrderController =
      TextEditingController();

  Map<int, double> productPrices = {};

  @override
  void initState() {
    super.initState();
    fetchData();
    if (widget.initialOrderIdToShowBill != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        _showBillDialog(context, widget.initialOrderIdToShowBill!); // ✅ ถูก
      });
    }
  }

  @override
  @override
  void dispose() {
    searchController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    totalPriceController.dispose();
    totalPriceOrderController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://192.168.17.133:3001/api/orders/orders')),
        http.get(
          Uri.parse('http://192.168.17.133:3001/api/products/products/stock'),
        ),
        http.get(
          Uri.parse('http://192.168.17.133:3001/api/customers/customers'),
        ),
        http.get(
          Uri.parse('http://192.168.17.133:3001/api/employees/employees'),
        ),
        http.get(
          Uri.parse('http://192.168.17.133:3001/api/exchanges'),
        ), // Add this line
      ]);

      final orderResponse = responses[0];
      final productResponse = responses[1];
      final customerResponse = responses[2];
      final employeeResponse = responses[3];
      final exchangeResponse = responses[4]; // Add this line

      if (orderResponse.statusCode == 200 &&
          productResponse.statusCode == 200 &&
          customerResponse.statusCode == 200 &&
          exchangeResponse.statusCode == 200) {
        // Update this condition
        final List<dynamic> ordersData = json.decode(orderResponse.body);
        final List<dynamic> productsData = json.decode(productResponse.body);
        final List<dynamic> customersData = json.decode(customerResponse.body);
        final List<dynamic> employeesData = json.decode(employeeResponse.body);
        final List<dynamic> exchangesData = json.decode(
          exchangeResponse.body,
        ); // Add this line

        setState(() {
          orders = ordersData.map((json) => Order.fromJson(json)).toList();
          filteredOrders = List.from(orders);
          products = productsData
              .map((json) => Product.fromJson(json))
              .toList();
          customers = customersData
              .map((json) => Customer.fromJson(json))
              .toList();
          employees = employeesData
              .map((json) => Employee.fromJson(json))
              .toList();
          exchangeRates = exchangesData
              .map((json) => ExchangeRate.fromJson(json))
              .toList(); // Add this line
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load one or more datasets.');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ຜິດພາດ: ${e.toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> addOrder(List<OrderItem> items, int? customerId) async {
    try {
      if (items.isEmpty) {
        throw Exception('ກະລຸນາເພີ່ມລາຍການສິນຄ້າກ່ອນ');
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('ບໍ່ພົບ user_id ຢູ່ໃນ SharedPreferences');
      }

      final totalPrice = items.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      final orderResponse = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/orders/orders'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(),
        },
        body: json.encode({
          'total_price': totalPrice,
          'customer_id': customerId,
        }),
      );

      if (orderResponse.statusCode == 200) {
        final responseData = json.decode(orderResponse.body);
        final orderId = responseData['orderId'];

        if (orderId == null) {
          throw Exception('ບໍ່ສາມາດເອົາ orderId ຈາກ response');
        }

        final itemsPayload = items
            .map(
              (item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
                'total_price': item.totalPrice,
              },
            )
            .toList();

        final itemResponse = await http.post(
          Uri.parse('http://192.168.17.133:3001/api/order_items/order_items'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'order_id': orderId, 'items': itemsPayload}),
        );

        if (itemResponse.statusCode != 200) {
          throw Exception('ບັນທຶກລາຍການສິນຄ້າບໍ່ສຳເລັດ');
        }

        await fetchData();

        if (mounted) {
          if (mounted) {
            _showPaymentConfirmationDialog(context, orderId);
          }
        }
      } else {
        final resData = json.decode(orderResponse.body);
        throw Exception(resData['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _showBillDialog(BuildContext context, int orderId) async {
    try {
      final billRes = await http.get(
        Uri.parse('http://192.168.17.133:3001/api/bills/bill/$orderId'),
      );
      final itemRes = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/order_items/order-items/$orderId',
        ),
      );

      if (billRes.statusCode == 200 && itemRes.statusCode == 200) {
        final billData = json.decode(billRes.body);
        final itemsData = json.decode(itemRes.body) as List<dynamic>;

        final bill = Bill.fromJson(billData);
        final List<OrderItem> orderItems = itemsData
            .map((item) => OrderItem.fromJson(item))
            .toList();

        // ใช้ข้อมูลจาก API แทนการค้นหาใน local list
        final order = Order(
          orderId: billData['order']['orderId'] ?? 0,
          customerId: billData['order']['customerId'],
          userId: billData['order']['userId'],
          totalPrice: billData['order']['totalPrice']?.toDouble() ?? 0.0,
          status: billData['order']['status'] ?? 'pending',
          createdAt: Order._parseLocalTime(billData['order']['createdAt']),
          updatedAt: Order._parseLocalTime(billData['order']['updatedAt']),
          customerName: billData['order']['customerName'],
          employeeName: billData['order']['employeeName'],
          items: orderItems, // เพิ่มรายการสินค้า
        );

        IconData statusIcon;
        Color statusColor;
        switch (order.status) {
          case 'completed':
            statusIcon = Icons.check_circle_rounded;
            statusColor = Colors.green;
            break;
          case 'cancelled':
            statusIcon = Icons.cancel_rounded;
            statusColor = Colors.red;
            break;
          default:
            statusIcon = Icons.hourglass_top_rounded;
            statusColor = Colors.orange;
        }
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 64),
                            SizedBox(height: 8),
                            Text(
                              'ໃບບິນ #${order.orderId}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Divider(thickness: 2),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'ຊື່ສິນຄ້າ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'ຈຳນວນ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'ລາຄາ/ອັນ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'ລາຄາລວມ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      ...orderItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(item.productName)),
                              Expanded(child: Text('${item.quantity}')),
                              Expanded(
                                child: Text(
                                  '${item.unitPrice.toStringAsFixed(2)}',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item.totalPrice.toStringAsFixed(2)}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ລາຄາລວມທັງໝົດ:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${order.totalPrice.toStringAsFixed(2)} ກີບ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ເງິນທີ່ຈ່າຍ:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${bill.amountMoney.toStringAsFixed(2)} ${bill.currencyCode ?? "LAK"}',
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ເງິນທອນ:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${bill.amountChange.toStringAsFixed(2)} ກີບ'),
                        ],
                      ),
                      // อัตราแลกเปลี่ยน
                      SizedBox(height: 8),
                      if (bill.currencyId != null &&
                          bill.exchangeRate != null &&
                          bill.currencyCode != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ອັດຕາແລກປ່ຽນ:'),
                            Text(
                              '1 ${bill.currencyCode} = ${bill.exchangeRate?.toStringAsFixed(2) ?? "-"} ກີບ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ອັດຕາແລກປ່ຽນ:'),
                            Text(
                              '1 LAK',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ຊື່ລູກຄ້າ:'),
                          Text(order.customerName ?? 'ບໍ່ມີຂໍ້ມູນ'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ຊື່ພະນັກງານ:'),
                          Text(order.employeeName ?? 'ບໍ່ມີຂໍ້ມູນ'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ວັນທີ:'),
                          Text(order.formattedCreatedAt),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: QrImageView(
                          data: '${order.orderId}',
                          version: QrVersions.auto,
                          size: 160.0,
                          gapless: false,
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.close),
                              label: Text('ປິດ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        String errorMessage;
        if (billRes.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ບໍ່ມີບິນນີ້',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        } else {
          errorMessage =
              '❌ ເກີດຂໍ້ຜິດພາດ\n'
              '• ບິນ: ${billRes.statusCode == 200 ? "ບໍ່ສຳເລັດ" : billRes.statusCode}\n'
              '• ລາຍການ: ${itemRes.statusCode == 200 ? "ບໍ່ສຳເລັດ" : itemRes.statusCode}\n'
              'ກະລຸນາລອງໃໝ່ພາຍຫຼັງ';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: ${e.toString()}')));
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.delete(
        Uri.parse('http://192.168.17.133:3001/api/orders/orders/$orderId'),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        await fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ລົບສຳເລັດ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        final resData = json.decode(response.body);
        String message = resData['message'] ?? 'ລົບບໍ່ສຳເລັດ';
        throw Exception(message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ຜິດພາດ: ${e.toString()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> searchOrders(String keyword) async {
    if (keyword.isEmpty) {
      fetchData();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/orders/orders/search/$keyword',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          filteredOrders = data.map((json) => Order.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('ຄົ້ນຫາບໍ່ສຳເລັດ');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString()}')),
        );
      }
    }
  }

  void _showUpdateDialog(
    int orderId,
    List<Customer> customers,
    int? currentCustomerId,
  ) {
    final _formKey = GlobalKey<FormState>();
    int? _selectedCustomerId = currentCustomerId;
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Color(0xFF0D0D2B),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.teal[700],
                          size: 36,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ແກ້ໄຂຊື່ລູກຄ້າ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Form(
                      key: _formKey,
                      child: DropdownButtonFormField<int>(
                        value: _selectedCustomerId,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ລູກຄ້າ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                          prefixIcon: Icon(
                            Icons.people,
                            color: Colors.teal[400],
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'ກະລຸນາເລືອກລູກຄ້າ';
                          }
                          return null;
                        },
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text(
                              'ເລືອກລູກຄ້າ',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ...customers.map((customer) {
                            return DropdownMenuItem<int>(
                              value: customer.customerId,
                              child: Container(
                                color: Color(0xFF0D0D2B),
                                child: Text(
                                  customer.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        dropdownColor: Color(0xFF0D0D2B),
                        onChanged: (value) {
                          setState(() {
                            _selectedCustomerId = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.close, color: Colors.teal),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.teal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          label: Text(
                            'ຍົກເລີກ',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        ElevatedButton.icon(
                          icon: _isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.save, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() => _isLoading = true);

                                    try {
                                      final response = await http.put(
                                        Uri.parse(
                                          'http://192.168.17.133:3001/api/orders/orders/$orderId/customer',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                        },
                                        body: jsonEncode({
                                          'customer_id': _selectedCustomerId,
                                        }),
                                      );

                                      if (!mounted) return;

                                      if (response.statusCode == 200) {
                                        Navigator.pop(context);
                                        fetchData();
                                        _showBillDialog(context, orderId);
                                      } else {
                                        final error =
                                            jsonDecode(
                                              response.body,
                                            )['message'] ??
                                            'ອັບເດດບໍ່ສຳເລັດ';
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    error,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'ຜິດພາດ: ${e.toString()}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  }
                                },
                          label: Text(
                            'ບັນທຶກ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentConfirmationDialog(BuildContext parentContext, int orderId) {
    final order = orders.firstWhere((o) => o.orderId == orderId);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController changeController = TextEditingController();
    changeController.text = '0.00';

    // Default to LAK (1:1 rate)
    ExchangeRate? selectedCurrency = ExchangeRate(
      id: 0,
      currencyCode: 'LAK',
      rate: 1.0,
      unit: 'LAK',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Color(0xFF0D0D2B),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments_rounded,
                          color: Colors.teal[700],
                          size: 36,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ຢືນຢັນການຊຳລະເງິນ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),

                    // Total amount row
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.teal[400]),
                        SizedBox(width: 8),
                        Text(
                          'ຍອດລວມ: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${order.totalPrice.toStringAsFixed(2)} ກີບ',
                                style: TextStyle(
                                  color: Colors.teal[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (selectedCurrency?.currencyCode != 'LAK') ...[
                                TextSpan(
                                  text: ' = ',
                                  style: TextStyle(
                                    color: Colors.teal[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${(order.totalPrice / (selectedCurrency?.rate ?? 1)).toStringAsFixed(2)} ${selectedCurrency?.currencyCode}',
                                  style: TextStyle(
                                    color: Colors.amber[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),

                    // Currency dropdown
                    DropdownButtonFormField<ExchangeRate>(
                      value: selectedCurrency,
                      dropdownColor: Color(0xFF1A1A3A),
                      decoration: InputDecoration(
                        labelText: 'ສະກຸນເງິນ',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0D0D2B),
                      ),
                      items: [
                        // Default LAK option
                        DropdownMenuItem(
                          value: ExchangeRate(
                            id: 0,
                            currencyCode: 'LAK',
                            rate: 1.0,
                            unit: 'LAK',
                          ),
                          child: Text(
                            'LAK 1',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // Add other currencies from exchangeRates
                        ...exchangeRates.map((rate) {
                          return DropdownMenuItem(
                            value: rate,
                            child: Text(
                              '${rate.currencyCode} ${rate.rate}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (ExchangeRate? newValue) {
                        setState(() {
                          selectedCurrency = newValue;
                          // Recalculate change if amount is already entered
                          if (amountController.text.isNotEmpty) {
                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            final change =
                                (amount * (selectedCurrency?.rate ?? 1)) -
                                order.totalPrice;
                            changeController.text = change.toStringAsFixed(2);
                          }
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Amount received field
                    TextField(
                      controller: amountController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText:
                            'ຈຳນວນເງິນ (${selectedCurrency?.currencyCode ?? ''})',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0D0D2B),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final amount = double.tryParse(value) ?? 0;
                          // Calculate change based on selected currency rate
                          final change =
                              (amount * (selectedCurrency?.rate ?? 1)) -
                              order.totalPrice;
                          setState(() {
                            changeController.text = change.toStringAsFixed(2);
                          });
                        } else {
                          setState(() {
                            changeController.text = '0.00';
                          });
                        }
                      },
                    ),
                    SizedBox(height: 14),

                    // Change field (in LAK)
                    TextField(
                      controller: changeController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'ເງິນທອນ (LAK)',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0D0D2B),
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 28),
                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.close, color: Colors.teal),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.teal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          label: Text(
                            'ຍົກເລີກ',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        ElevatedButton.icon(
                          icon: Icon(Icons.check_circle, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () async {
                            final dialogContext = context;

                            if (amountController.text.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'ກະລຸນາປ້ອນຈຳນວນເງິນ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            final amount =
                                double.tryParse(amountController.text) ?? 0;
                            final amountInLak =
                                amount * (selectedCurrency?.rate ?? 1);

                            if (amountInLak < order.totalPrice) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(
                                            0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.redAccent,
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          'ເງິນຊຳລະບໍ່ພໍ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Color(0xFF0D0D2B),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  duration: Duration(seconds: 3),
                                  elevation: 6,
                                ),
                              );
                              return;
                            }

                            try {
                              final response = await http.post(
                                Uri.parse(
                                  'http://192.168.17.133:3001/api/bills/bills',
                                ),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({
                                  'order_id': orderId,
                                  'amount_money': double.tryParse(
                                    amountController.text,
                                  ),
                                  'amount_change': double.parse(
                                    changeController.text,
                                  ),
                                  'currency_id': selectedCurrency?.id ?? null,
                                  'exchange_rate': selectedCurrency?.rate ?? 1,
                                }),
                              );

                              if (response.statusCode == 200) {
                                Navigator.of(
                                  dialogContext,
                                  rootNavigator: true,
                                ).pop();
                                totalPriceOrderController.clear();
                                _tempItems.clear();
                                fetchData();
                                _showBillDialog(parentContext, orderId);
                              } else {
                                throw Exception('ສ້າງບິນບໍ່ສຳເລັດ');
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'ຜິດພາດ: ${e.toString()}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFF0D0D2B),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          label: Text(
                            'ຢືນຢັນການຊຳລະເງິນ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF0D0D2B),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          constraints: BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(18),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'ຢືນຢັນການລົບ',
                style: TextStyle(
                  color: Colors.teal[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'ທ່ານແນ່ໃຈບໍ່ວ່າຈະລົບ?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.close, color: Colors.teal),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    label: Text(
                      'ຍົກເລີກ',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    label: Text(
                      'ລົບ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await deleteOrder(orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຂາຍສິນຄ້າ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B1B4D),
        elevation: 4,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                tooltip: 'ສະແກນ QR COde',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRScannerPage(
                        onOrderIdScanned: (orderId) =>
                            _showBillDialog(context, orderId),
                      ),
                    ),
                  );
                },
              ),

              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                tooltip: 'ໂຫຼດໃໝ່',
                onPressed: fetchData,
              ),
            ],
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
          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຄົ້ນຫາການສັ່ງຊື້',
                          labelStyle: TextStyle(color: Colors.purpleAccent),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purpleAccent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurple,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor: Colors.white.withOpacity(0.08),
                          filled: true,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        onChanged: (value) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            if (value == searchController.text) {
                              searchOrders(value);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.purpleAccent,
                        ),
                      )
                    : filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ບໍ່ມີການສັ່ງຊື້'
                              : 'ບໍ່ພົບການສັ່ງຊື້',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final Order = filteredOrders[index];
                          final productNames = Order.items.isNotEmpty
                              ? Order.items
                                    .map((item) => item.productName)
                                    .join(', ')
                              : 'ບໍ່ມີສິນຄ້າ';

                          // Determine status color
                          IconData statusIcon;
                          Color statusColor;
                          switch (Order.status) {
                            case 'completed':
                              statusIcon = Icons.check_circle;
                              statusColor = Colors.green;
                              break;
                            case 'cancelled':
                              statusIcon = Icons.cancel;
                              statusColor = Colors.red;
                              break;
                            default:
                              statusIcon = Icons.access_time;
                              statusColor = Colors.orange;
                          }

                          return Card(
                            color: const Color(0xFF23235B),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purpleAccent,
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    WidgetSpan(child: SizedBox(width: 6)),
                                    TextSpan(
                                      text:
                                          '#${Order.orderId.toString().padLeft(4, '0')} ',
                                    ),
                                    TextSpan(
                                      text: '(${Order.status})',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                productNames,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.receipt,
                                      color: Order.status == 'pending'
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: () =>
                                        _showBillDialog(context, Order.orderId),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Order.status == 'pending'
                                          ? Icons.payment
                                          : Icons.edit,
                                      color: Order.status == 'pending'
                                          ? Colors.purpleAccent
                                          : Colors.blueAccent,
                                    ),
                                    onPressed: () {
                                      if (Order.status == 'pending') {
                                        _showPaymentConfirmationDialog(
                                          context,
                                          Order.orderId,
                                        ); // ✅
                                      } else {
                                        _showUpdateDialog(
                                          Order.orderId,
                                          customers,
                                          Order.customerId,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          Order.orderId,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.purpleAccent,
        label: Text(
          'ເພີ່ມການສັ່ງຊື້',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => SellOrderDialog(
              products: products,
              customers: customers,
              onSubmit: (items, customerId) {
                addOrder(items, customerId);
              },
            ),
          );
        },
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  final void Function(int orderId) onOrderIdScanned;

  const QRScannerPage({Key? key, required this.onOrderIdScanned})
    : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('ສະແກນ QR'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) async {
          if (_isProcessing) return; // ✅ ป้องกันการทำงานซ้ำ

          _isProcessing = true;
          final barcode = capture.barcodes.first;
          final String code = barcode.rawValue ?? "";

          // หยุดสแกนทันที
          scannerController.stop();

          if (code.isNotEmpty) {
            final int? orderId = int.tryParse(code);
            if (orderId != null) {
              Navigator.pop(context); // ปิดกล้อง
              await Future.delayed(Duration(milliseconds: 300));
              widget.onOrderIdScanned(orderId);
            } else {
              _showError("QR ບໍ່ຖືກຕ້ອງ");
            }
          } else {
            _showError("ບໍ່ຮູ້ຈັກ QR");
          }
        },
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ຂໍ້ຜິດພາດ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ปิด dialog
              scannerController.start(); // ✅ กลับมาสแกนอีกครั้ง
              _isProcessing = false; // ✅ อนุญาตให้สแกนรอบต่อไป
            },
            child: Text('ຕົກລົງ'),
          ),
        ],
      ),
    );
  }
}

class SellOrderDialog extends StatefulWidget {
  final List<Product> products;
  final List<Customer> customers;
  final Function(List<OrderItem>, int?) onSubmit;

  const SellOrderDialog({
    required this.products,
    required this.customers,
    required this.onSubmit,
  });

  @override
  _SellOrderDialogState createState() => _SellOrderDialogState();
}

class _SellOrderDialogState extends State<SellOrderDialog> {
  int? selectedProductId;
  int? selectedCustomerId;
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final totalPriceController = TextEditingController();
  final totalPriceOrderController = TextEditingController(text: '0.00');

  final List<OrderItem> tempItems = [];
  bool isAutoAdd = false;

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    totalPriceController.dispose();
    totalPriceOrderController.dispose();
    super.dispose();
  }

  Future<Product?> fetchProductByBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.17.133:3001/api/products/products/barcode/$barcode',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Product.fromJson(json);
    } else {
      return null;
    }
  }

  void _calculateTotalPrice(int? productId, String quantityStr) {
    final quantity = int.tryParse(quantityStr) ?? 0;
    final product = widget.products.firstWhere(
      (p) => p.productId == productId,
      orElse: () => Product(productId: 0, name: '', price: 0, stockQuantity: 0),
    );

    if (product.productId != 0) {
      final unitPrice = product.price * 1.1;
      final total = quantity * unitPrice;

      unitPriceController.text = unitPrice.toStringAsFixed(2);
      totalPriceController.text = total.toStringAsFixed(2);
    } else {
      unitPriceController.clear();
      totalPriceController.clear();
    }
  }

  bool _isStockEnough(int productId, int quantityToAdd) {
    final product = widget.products.firstWhere((p) => p.productId == productId);

    final alreadyInTemp = tempItems
        .where((item) => item.productId == productId)
        .fold<int>(0, (sum, item) => sum + item.quantity);
    final remainingStock = product.stockQuantity - alreadyInTemp;

    return remainingStock >= quantityToAdd;
  }

  void _recalculateTotalOrderPrice() {
    final total = tempItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    totalPriceOrderController.text = total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B4D),
        title: Text(
          'ຂາຍສິນຄ້າ',
          style: TextStyle(
            color: Colors.teal[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product dropdown
            DropdownButtonFormField<int?>(
              value: selectedProductId,
              dropdownColor: Color(0xFF0D0D2B),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'ເລືອກສິນຄ້າ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ...widget.products.map((p) {
                  return DropdownMenuItem<int?>(
                    value: p.productId,
                    child: Text(p.name, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ],
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration('ສິນຄ້າ'),
              onChanged: (val) {
                setState(() {
                  selectedProductId = val;
                });
                _calculateTotalPrice(val, quantityController.text);
              },
            ),
            const SizedBox(height: 14),

            // Quantity
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: _inputDecoration('ຈຳນວນ'),
              onChanged: (val) => _calculateTotalPrice(selectedProductId, val),
            ),
            const SizedBox(height: 14),

            // Price
            TextField(
              controller: unitPriceController,
              readOnly: true,
              decoration: _inputDecoration('ລາຄາ'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Total
            TextField(
              controller: totalPriceController,
              readOnly: true,
              decoration: _inputDecoration('ລາຄາລວມ'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isAutoAdd,
                      onChanged: (val) {
                        setState(() {
                          isAutoAdd = val ?? false;
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.teal,
                    ),
                    Text(
                      "ເພິ່ມອັດຕະໂນມັດ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('ເພີ່ມສິນຄ້າ'),
                  onPressed: () {
                    final productId = selectedProductId;
                    final quantity = int.tryParse(quantityController.text) ?? 0;

                    if (productId == null || quantity <= 0) return;

                    if (!_isStockEnough(productId, quantity)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("ສິນຄ້າບໍ່ພຽງພໍ"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final product = widget.products.firstWhere(
                      (p) => p.productId == productId,
                    );
                    final unitPrice = product.price * 1.1;

                    setState(() {
                      // ตรวจสอบว่ามีรายการนี้อยู่แล้วไหม
                      final index = tempItems.indexWhere(
                        (item) => item.productId == productId,
                      );

                      if (index >= 0) {
                        // ถ้ามีแล้ว ให้เพิ่มจำนวน และคำนวณราคาทั้งหมดใหม่
                        final existingItem = tempItems[index];
                        final newQuantity = existingItem.quantity + quantity;
                        final newTotalPrice = newQuantity * unitPrice;

                        tempItems[index] = OrderItem(
                          orderId: existingItem.orderId,
                          productId: existingItem.productId,
                          productName: existingItem.productName,
                          quantity: newQuantity,
                          unitPrice: unitPrice,
                          totalPrice: newTotalPrice,
                        );
                      } else {
                        // ถ้ายังไม่มี เพิ่มใหม่เลย
                        tempItems.add(
                          OrderItem(
                            orderId: 0,
                            productId: product.productId,
                            productName: product.name,
                            quantity: quantity,
                            unitPrice: unitPrice,
                            totalPrice: quantity * unitPrice,
                          ),
                        );
                      }

                      selectedProductId = null;
                      quantityController.clear();
                      unitPriceController.clear();
                      totalPriceController.clear();
                      _recalculateTotalOrderPrice();
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (tempItems.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tempItems.length,
                itemBuilder: (_, i) {
                  final item = tempItems[i];
                  return ListTile(
                    title: Text(
                      item.productName,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "₭${item.unitPrice.toStringAsFixed(2)} ×${item.quantity} = ₭${item.totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          tempItems.removeAt(i);
                          _recalculateTotalOrderPrice();
                        });
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            TextField(
              controller: totalPriceOrderController,
              readOnly: true,
              decoration: _inputDecoration('ລາຄາທັງໝົດ'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int?>(
              value: selectedCustomerId,
              decoration: _inputDecoration('ລູກຄ້າ'),
              dropdownColor: Color(0xFF0D0D2B),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('ບໍ່ມີ', style: TextStyle(color: Colors.white)),
                ),
                ...widget.customers.map(
                  (c) => DropdownMenuItem(
                    value: c.customerId,
                    child: Text(c.name, style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => selectedCustomerId = val),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.cancel),
                  label: Text(
                    "ຍົກເລີກ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedProductId = null;
                      quantityController.clear();
                      unitPriceController.clear();
                      totalPriceController.clear();
                      tempItems.clear();
                    });
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.check),
                  label: Text(
                    "ຊື້ເລີຍ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    if (tempItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("ກະລຸນາເພີ່ມສິນຄ້າກ່ອນ!")),
                      );
                      return;
                    }
                    widget.onSubmit(tempItems, selectedCustomerId);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.qr_code_scanner, color: Colors.white),
        backgroundColor: Colors.teal,
        label: Text(
          'ສະແກນ Barcode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final scannedBarcode = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => ProductBarcodeScannerPage()),
          );

          if (scannedBarcode != null) {
            final List<Product> matched = widget.products
                .where((p) => p.barcode == scannedBarcode)
                .toList();

            Product? foundProduct = matched.isNotEmpty ? matched.first : null;

            if (foundProduct == null) {
              foundProduct = await fetchProductByBarcode(scannedBarcode);

              if (foundProduct != null) {
                final exists = widget.products.any(
                  (p) => p.productId == foundProduct!.productId,
                );
                if (!exists) {
                  setState(() {
                    widget.products.add(foundProduct!);
                  });
                }
              }
            }

            if (foundProduct != null) {
              if (isAutoAdd) {
                final unitPrice = foundProduct.price * 1.1;

                // ✅ เช็ก stock ก่อน
                final stockOk = _isStockEnough(foundProduct.productId, 1);
                if (!stockOk) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("ສິນຄ້າ '${foundProduct.name}' ບໍ່ພຽງພໍ"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // ❌ ไม่เพิ่มถ้า stock ไม่พอ
                }

                setState(() {
                  final index = tempItems.indexWhere(
                    (item) => item.productId == foundProduct!.productId,
                  );

                  if (index >= 0) {
                    final existingItem = tempItems[index];
                    final newQuantity = existingItem.quantity + 1;
                    final newTotalPrice = newQuantity * unitPrice;

                    tempItems[index] = OrderItem(
                      orderId: existingItem.orderId,
                      productId: existingItem.productId,
                      productName: existingItem.productName,
                      quantity: newQuantity,
                      unitPrice: unitPrice,
                      totalPrice: newTotalPrice,
                    );
                  } else {
                    tempItems.add(
                      OrderItem(
                        orderId: 0,
                        productId: foundProduct!.productId,
                        productName: foundProduct.name,
                        quantity: 1,
                        unitPrice: unitPrice,
                        totalPrice: unitPrice,
                      ),
                    );
                  }

                  _recalculateTotalOrderPrice();
                  selectedProductId = null;
                  quantityController.clear();
                  unitPriceController.clear();
                  totalPriceController.clear();
                });
              } else {
                // กรณีไม่ติ๊ก auto add
                final existsInList = widget.products.any(
                  (p) => p.productId == foundProduct!.productId,
                );

                if (!existsInList) {
                  setState(() {
                    widget.products.add(foundProduct!);
                  });
                }

                setState(() {
                  selectedProductId = foundProduct!.productId;
                  quantityController.text = '1';
                  _calculateTotalPrice(
                    selectedProductId,
                    quantityController.text,
                  );
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ບໍ່ພົບສິນຄ້າຈາກ Barcode'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Color(0xFF1A1A3C),
  );
}

class ProductBarcodeScannerPage extends StatefulWidget {
  const ProductBarcodeScannerPage({Key? key}) : super(key: key);

  @override
  _ProductBarcodeScannerPageState createState() =>
      _ProductBarcodeScannerPageState();
}

class _ProductBarcodeScannerPageState extends State<ProductBarcodeScannerPage> {
  bool hasScanned = false; // เพื่อป้องกันสแกนซ้ำ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ສະແກນ Barcode'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: Color(0xFF0D0D2B),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          if (hasScanned) return;
          final barcode = barcodeCapture.barcodes.first.rawValue ?? '';

          if (barcode.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('ບໍ່ພົບຂໍ້ມູນ Barcode')));
            return;
          }

          setState(() => hasScanned = true);
          Navigator.of(context).pop(barcode);
        },
      ),
    );
  }
}
