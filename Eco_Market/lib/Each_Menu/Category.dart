import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Category {
  final int categoryId;
  final String name;
  final DateTime createdAt;

  Category({
    required this.categoryId,
    required this.name,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = search != null && search.isNotEmpty
          ? Uri.parse(
              'http://192.168.17.133:3001/api/categories/categories/$search',
            )
          : Uri.parse('http://192.168.17.133:3001/api/categories/categories');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
          filteredCategories = List.from(categories);
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

  Future<void> addCategory(Category category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/categories/categories'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
        body: json.encode({'name': category.name}),
      );

      if (response.statusCode == 200) {
        fetchCategories();
      } else {
        final resData = json.decode(response.body);
        throw Exception(resData['message'] ?? 'ເພິ່ມບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final response = await http.put(
        Uri.parse(
          'http://192.168.17.133:3001/api/categories/categories/${category.categoryId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
        body: json.encode({'name': category.name}),
      );

      if (response.statusCode == 200) {
        fetchCategories();
      } else {
        throw Exception('ແກ້ໄຂບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      // ดึง user_id จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getInt('user_id') ?? 0; // ใช้ 0 หรือค่า default อื่นๆ ถ้าไม่มี

      final response = await http.delete(
        Uri.parse(
          'http://192.168.17.133:3001/api/categories/categories/$categoryId',
        ),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        fetchCategories();
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

  void _showAddEditCategoryDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Color(0xFF1B1B4D),
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
                            category == null ? Icons.add : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            category == null ? 'ເພິ່ມປະເພດ' : 'ແກ້ໄຂປະເພດ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      // Name field
                      TextField(
                        controller: nameController,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຊື່ປະເພດ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1B1B4D),
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
                              child: Text('ຍົກເລິກ'),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              String? emptyField;
                              if (nameController.text.trim().isEmpty) {
                                emptyField = 'ຊື່ປະເພດ';
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
                              final newCategory = Category(
                                categoryId: category?.categoryId ?? 0,
                                name: nameController.text,
                                createdAt:
                                    category?.createdAt ?? DateTime.now(),
                              );
                              try {
                                if (category == null) {
                                  await addCategory(newCategory);
                                } else {
                                  await updateCategory(newCategory);
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
                                category == null ? 'ບັນທຶກ' : 'ບັນທຶກ',
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

  void _showDeleteConfirmationDialog(int categoryId) async {
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
        await deleteCategory(categoryId);
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
            Icon(Icons.category, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຈັດການປະເພດສິນຄ້າ',
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
            onPressed: () => fetchCategories(),
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
                          labelText: 'ຄົ້ນຫາປະເພດສິນຄ້າ',
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
                                fetchCategories(search: searchController.text),
                          ),
                        ),
                        onChanged: (value) => fetchCategories(search: value),
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
                    : filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ກຳລັງໂຫຼດຂໍ້ມູນ...'
                              : 'ບໍ່ພົບຂໍ້ມູນ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
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
                                category.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () => _showAddEditCategoryDialog(
                                      category: category,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          category.categoryId,
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
        onPressed: () => _showAddEditCategoryDialog(),
        tooltip: 'ເພີ່ມປະເພດໃໝ່',
        elevation: 6,
      ),
    );
  }
}
