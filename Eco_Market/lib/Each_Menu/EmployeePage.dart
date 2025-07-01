import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  final int employeeId;
  final String name;
  final String lastname;
  final String phone;
  final String email;
  final String role;
  final String address;
  final DateTime createdAt;

  Employee({
    required this.employeeId,
    required this.name,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.role,
    required this.address,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      name: json['name'],
      lastname: json['lastname'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class EmployeeManagementPage extends StatefulWidget {
  @override
  _EmployeeManagementPageState createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final List<String> _roles = ['admin', 'cashier', 'manager'];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = search != null && search.isNotEmpty
          ? Uri.parse(
              'http://192.168.17.133:3001/api/employees/employees/search/$search',
            )
          : Uri.parse('http://192.168.17.133:3001/api/employees/employees');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          employees = data.map((json) => Employee.fromJson(json)).toList();
          filteredEmployees = List.from(employees);
          isLoading = false;
        });
      } else {
        throw Exception('ໂຫຼດຂໍ້ມູນບໍ່ໄດ້');
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

  Future<void> addEmployee(Employee employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/employees/employees'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': employee.name,
          'lastname': employee.lastname,
          'phone': employee.phone,
          'email': employee.email,
          'role': employee.role,
          'address': employee.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchEmployees();
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

  Future<void> updateEmployee(Employee employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.put(
        Uri.parse(
          'http://192.168.17.133:3001/api/employees/employees/${employee.employeeId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': employee.name,
          'lastname': employee.lastname,
          'phone': employee.phone,
          'email': employee.email,
          'role': employee.role,
          'address': employee.address,
        }),
      );

      if (response.statusCode == 200) {
        fetchEmployees();
      } else {
        throw Exception('ແກ້ໄຂບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.delete(
        Uri.parse(
          'http://192.168.17.133:3001/api/employees/employees/$employeeId',
        ),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        fetchEmployees();
      } else {
        final resData = json.decode(response.body);
        String message = resData['message'] ?? 'ລົບລົ້ມເລວ';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  void _showAddEditEmployeeDialog({Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final lastnameController = TextEditingController(
      text: employee?.lastname ?? '',
    );
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final addressController = TextEditingController(
      text: employee?.address ?? '',
    );
    String? selectedRole = employee?.role;

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
                            employee == null ? Icons.person_add : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            employee == null
                                ? 'ເພີ່ມພະນັກງານ'
                                : 'ແກ້ໄຂພະນັກງານ',
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
                      // Lastname
                      TextField(
                        controller: lastnameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ນາມສະກຸນ',
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
                      // Role
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ໜ້າທີ່',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        dropdownColor: Color(0xFF0D0D2B),
                        items: _roles.map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedRole = newValue;
                          });
                        },
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
                        maxLines: 2,
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
                              child: Text('ຍົກເລິກ'),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              String? emptyField;

                              if (nameController.text.trim().isEmpty) {
                                emptyField = 'ຊື່';
                              } else if (lastnameController.text
                                  .trim()
                                  .isEmpty) {
                                emptyField = 'ນາມສະກຸນ';
                              } else if (phoneController.text.trim().isEmpty) {
                                emptyField = 'ເບີໂທ';
                              } else if (emailController.text.trim().isEmpty) {
                                emptyField = 'ອີເມວ';
                              } else if (selectedRole == null ||
                                  selectedRole!.trim().isEmpty) {
                                emptyField = 'ໜ້າທີ່';
                              } else if (addressController.text
                                  .trim()
                                  .isEmpty) {
                                emptyField = 'ທີ່ຢູ່';
                              }

                              if (emptyField != null) {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      false, // ป้องกันการกดข้างนอกเพื่อปิด
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

                              final newEmployee = Employee(
                                employeeId: employee?.employeeId ?? 0,
                                name: nameController.text,
                                lastname: lastnameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                role: selectedRole!,
                                address: addressController.text,
                                createdAt:
                                    employee?.createdAt ?? DateTime.now(),
                              );

                              try {
                                if (employee == null) {
                                  await addEmployee(newEmployee);
                                } else {
                                  await updateEmployee(newEmployee);
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
                                employee == null ? 'ບັນທຶກ' : 'ບັນທຶກ',
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

  void _showDeleteConfirmationDialog(int employeeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Color(0xFF0D0D2B),
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
        await deleteEmployee(employeeId);
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
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຂໍ້ມູນພະນັກງານ',
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
            onPressed: () => fetchEmployees(),
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
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຄົ້ນຫາພະນັກງານ',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.purpleAccent,
                            ),
                            onPressed: () =>
                                fetchEmployees(search: searchController.text),
                          ),
                        ),
                        onChanged: (value) => fetchEmployees(search: value),
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
                    : filteredEmployees.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ບໍ່ພົບຂໍ້ມູນພະນັກງານ'
                              : 'ບໍ່ພົບຂໍ້ມູນ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
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
                                '${employee.name} ${employee.lastname}',
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
                                    'ໜ້າທີ່: ${employee.role}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'ເບີໂທ: ${employee.phone}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'ອີເມລ: ${employee.email}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'ທີ່ຢູ່: ${employee.address}',
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
                                    onPressed: () => _showAddEditEmployeeDialog(
                                      employee: employee,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          employee.employeeId,
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
        label: Text('ເພີ່ມພະນັກງານ'),
        backgroundColor: Colors.purpleAccent,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditEmployeeDialog(),
        elevation: 6,
      ),
    );
  }
}
