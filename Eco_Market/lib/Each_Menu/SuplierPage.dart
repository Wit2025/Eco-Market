import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Supplier {
  final int supplierId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final DateTime createdAt;

  Supplier({
    required this.supplierId,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierId: json['supplier_id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class SupplierManagementPage extends StatefulWidget {
  @override
  _SupplierManagementPageState createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  List<Supplier> suppliers = [];
  List<Supplier> filteredSuppliers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = search != null && search.isNotEmpty
          ? Uri.parse(
              'http://192.168.17.133:3001/api/suppliers/suppliers/search/$search',
            )
          : Uri.parse('http://192.168.17.133:3001/api/suppliers/suppliers');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          suppliers = data.map((json) => Supplier.fromJson(json)).toList();
          filteredSuppliers = List.from(suppliers);
          isLoading = false;
        });
      } else {
        throw Exception('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນ');
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

  Future<void> addSupplier(Supplier supplier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/suppliers/suppliers'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': supplier.name,
          'phone': supplier.phone,
          'email': supplier.email,
          'address': supplier.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchSuppliers();
      } else {
        final resData = json.decode(response.body);
        throw Exception(resData['message'] ?? 'ເພີ່ມບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.put(
        Uri.parse(
          'http://192.168.17.133:3001/api/suppliers/suppliers/${supplier.supplierId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': supplier.name,
          'phone': supplier.phone,
          'email': supplier.email,
          'address': supplier.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchSuppliers();
      } else {
        throw Exception('ແກ້ໄຂບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteSupplier(int supplierId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.delete(
        Uri.parse(
          'http://192.168.17.133:3001/api/suppliers/suppliers/$supplierId',
        ),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        fetchSuppliers();
      } else {
        final resData = json.decode(response.body);
        String message = resData['message'] ?? 'ລົບບໍ່ສຳເລັດ';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  void _showAddEditSupplierDialog({Supplier? supplier}) {
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(
      text: supplier?.address ?? '',
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
              backgroundColor: const Color(0xFF0D0D2B),
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
                            supplier == null ? Icons.person_add : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            supplier == null
                                ? 'ເພີ່ມຜູ້ສະໜອງ'
                                : 'ແກ້ໄຂຜູ້ສະໜອງ',
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
                          fillColor: Color(0xFF0D0D2B),
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
                          fillColor: Color(0xFF0D0D2B),
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
                          fillColor: Color(0xFF0D0D2B),
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
                          fillColor: Color(0xFF0D0D2B),
                        ),
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

                              final newSupplier = Supplier(
                                supplierId: supplier?.supplierId ?? 0,
                                name: nameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                address: addressController.text,
                                createdAt:
                                    supplier?.createdAt ?? DateTime.now(),
                              );

                              try {
                                if (supplier == null) {
                                  await addSupplier(newSupplier);
                                } else {
                                  await updateSupplier(newSupplier);
                                }
                                Navigator.pop(dialogContext);
                              } catch (e) {
                                // Error is already shown via SnackBar
                              }
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
                                'ບັນທຶກ',
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

  void _showDeleteConfirmationDialog(int supplierId) async {
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
      try {
        await deleteSupplier(supplierId);
      } catch (e) {
        // Error is already shown via SnackBar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ລາຍຊື່ຜູ້ສະໜອງສິນຄ້າ',
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
            onPressed: () => fetchSuppliers(),
          ),
        ],
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
                          labelText: 'ຄົ້ນຫາຂໍ້ມູນ',
                          labelStyle: TextStyle(color: Colors.purpleAccent),
                          hintText: 'ປ້ອນຊື່, ເບີໂທ, ອີເມລ ຫຼື ທີ່ຢູ່',
                          hintStyle: TextStyle(color: Colors.white54),
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.purpleAccent,
                            ),
                            onPressed: () =>
                                fetchSuppliers(search: searchController.text),
                          ),
                        ),
                        onChanged: (value) => fetchSuppliers(search: value),
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
                    : filteredSuppliers.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ກຳລັງໂຫຼດຂໍ້ມູນ...'
                              : 'ບໍ່ພົບຂໍ້ມູນ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = filteredSuppliers[index];
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
                              title: Text(
                                supplier.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ເບີໂທ: ${supplier.phone}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'ອີເມລ: ${supplier.email}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'ທີ່ຢູ່: ${supplier.address}',
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
                                    onPressed: () => _showAddEditSupplierDialog(
                                      supplier: supplier,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          supplier.supplierId,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditSupplierDialog(),
        tooltip: 'ເພີ່ມຜູ້ສະໜອງ',
        elevation: 6,
      ),
    );
  }
}
