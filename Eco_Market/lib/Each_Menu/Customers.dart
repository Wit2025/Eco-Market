import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Customer {
  final int customerId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;

  Customer({
    required this.customerId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CustomerManagementPage extends StatefulWidget {
  @override
  _CustomerManagementPageState createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = search != null && search.isNotEmpty
          ? Uri.parse(
              'http://192.168.17.133:3001/api/customers/customers/search/$search',
            )
          : Uri.parse('http://192.168.17.133:3001/api/customers/customers');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          customers = data.map((json) => Customer.fromJson(json)).toList();
          filteredCustomers = List.from(customers);
          isLoading = false;
        });
      } else {
        throw Exception('ໂຫຼດຂໍ້ມຼລບໍ່ໄດ້');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/customers/customers'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
        body: json.encode({
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchCustomers();
      } else {
        throw Exception('ເພີ່ມບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final response = await http.put(
        Uri.parse(
          'http://192.168.17.133:3001/api/customers/customers/${customer.customerId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
        body: json.encode({
          'name': customer.name,
          'phone': customer.phone,
          'email': customer.email,
          'address': customer.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchCustomers();
      } else {
        throw Exception('ແກ້ໄຂບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.delete(
        Uri.parse(
          'http://192.168.17.133:3001/api/customers/customers/$customerId',
        ),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        fetchCustomers();
      } else {
        throw Exception('ລົບບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _showAddEditCustomerDialog({Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(
      text: customer?.address ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Color(0xFF0D0D2B),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                constraints: BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            customer == null ? Icons.person_add : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            customer == null ? 'ເພີ່ມລູກຄ້າ' : 'ແກ້ໄຂລູກຄ້າ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      // Name
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຊື່',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1B1B4D),
                        ),
                      ),
                      SizedBox(height: 14),
                      // Phone
                      TextField(
                        controller: phoneController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ເບີໂທ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1B1B4D),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 14),
                      // Email
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ອີເມລ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1B1B4D),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 14),
                      // Address
                      TextField(
                        controller: addressController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ທີ່ຢູ່',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1B1B4D),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: BorderSide(color: Colors.teal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text('ຍົກເລີກ'),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              String? emptyField;
                              if (nameController.text.trim().isEmpty) {
                                emptyField = 'ຊື່';
                              } else if (phoneController.text.trim().isEmpty) {
                                emptyField = 'ເບີໂທ';
                              } else if (emailController.text.trim().isEmpty) {
                                emptyField = 'ອີເມລ';
                              } else if (addressController.text
                                  .trim()
                                  .isEmpty) {
                                emptyField = 'ທີ່ຢູ່';
                              }

                              if (emptyField != null) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.white,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 28,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.redAccent.shade100,
                                            Colors.red.shade300,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.shade200
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              'ກະລຸນາປ້ອນ "$emptyField"',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                await Future.delayed(Duration(seconds: 2));
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                return;
                              }

                              final newCustomer = Customer(
                                customerId: customer?.customerId ?? 0,
                                name: nameController.text,
                                phone: phoneController.text.isEmpty
                                    ? null
                                    : phoneController.text,
                                email: emailController.text.isEmpty
                                    ? null
                                    : emailController.text,
                                address: addressController.text.isEmpty
                                    ? null
                                    : addressController.text,
                                createdAt:
                                    customer?.createdAt ?? DateTime.now(),
                              );

                              if (customer == null) {
                                await addCustomer(newCustomer);
                              } else {
                                await updateCustomer(newCustomer);
                              }

                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              child: Text(
                                customer == null ? 'ບັນທຶກ' : 'ບັນທຶກ',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.people, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຈັດການລູກຄ້າ',
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
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'ໂຫຼດໃໝ່',
            onPressed: () => fetchCustomers(),
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
                  colors: [Colors.tealAccent, Colors.teal.shade700],
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
                          labelText: 'ຄົ້ນຫາລູກຄ້າ',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.tealAccent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor: Colors.white.withOpacity(0.08),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.tealAccent),
                            onPressed: () =>
                                fetchCustomers(search: searchController.text),
                          ),
                        ),
                        onChanged: (value) => fetchCustomers(search: value),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      )
                    : filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ກຳລັງໂຫຼດຂໍ້ມູນ...'
                              : 'ບໍ່ພົບຂໍ້ມູນລູກຄ້າ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return Card(
                            color: const Color(0xFF23235B),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.tealAccent,
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (customer.phone != null)
                                    Text(
                                      'ເບີໂທ: ${customer.phone}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  if (customer.email != null)
                                    Text(
                                      'ອີເມລ: ${customer.email}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  if (customer.address != null)
                                    Text(
                                      'ທີ່ຢູ່: ${customer.address}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () => _showAddEditCustomerDialog(
                                      customer: customer,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          backgroundColor: Color(0xFF1B1B4D),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 28,
                                              vertical: 28,
                                            ),
                                            constraints: BoxConstraints(
                                              maxWidth: 380,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.1),
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    OutlinedButton.icon(
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: Colors.teal,
                                                      ),
                                                      style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                          color: Colors.teal,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 18,
                                                              vertical: 10,
                                                            ),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      label: Text(
                                                        'ຍົກເລີກ',
                                                        style: TextStyle(
                                                          color: Colors.teal,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 14),
                                                    ElevatedButton.icon(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.redAccent,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        elevation: 3,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      label: Text(
                                                        'ລົບ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                        await deleteCustomer(
                                          customer.customerId,
                                        );
                                      }
                                    },
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
        backgroundColor: Colors.tealAccent,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text('ເພີ່ມລູກຄ້າ', style: TextStyle(color: Colors.black)),
        onPressed: () => _showAddEditCustomerDialog(),
        elevation: 6,
      ),
    );
  }
}
