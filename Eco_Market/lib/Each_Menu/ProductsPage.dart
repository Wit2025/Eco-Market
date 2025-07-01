import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_widget/barcode_widget.dart';

class Product {
  final int productId;
  final String name;
  final String? description; // Make nullable
  final double price;
  final int stockQuantity;
  final int? unitId;
  final String? unitName;
  final int? categoryId;
  final String? categoryName;
  final int? supplierId;
  final String? supplierName;
  final String? barcode; // Make nullable
  final DateTime createdAt;

  Product({
    required this.productId,
    required this.name,
    this.description, // Now optional
    required this.price,
    required this.stockQuantity,
    this.unitId,
    this.unitName,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
    this.barcode, // Now optional
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      unitId: json['unit_id'],
      unitName: json['unit_name'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      barcode: json['barcode'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ProductManagementPage extends StatefulWidget {
  final int? productId;

  const ProductManagementPage({Key? key, this.productId}) : super(key: key);

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  List<dynamic> units = [];
  List<dynamic> categories = [];
  List<dynamic> suppliers = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchUnits();
    fetchCategories();
    fetchSuppliers();
    loadDataAndOpenDialog();
  }

  Future<void> loadDataAndOpenDialog() async {
    await fetchProducts();
    await fetchUnits();
    await fetchCategories();
    await fetchSuppliers();

    // 🔍 ค้นหาสินค้าจาก productId
    Product? selectedProduct =
        products.where((p) => p.productId == widget.productId).isNotEmpty
        ? products.firstWhere((p) => p.productId == widget.productId)
        : null;
    // ✅ ถ้าพบ product → เปิด dialog
    if (selectedProduct != null) {
      _showAddEditProductDialog(product: selectedProduct);
    }
  }

  Future<void> fetchProducts({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = search != null && search.isNotEmpty
          ? Uri.parse(
              'http://192.168.17.133:3001/api/products/products/search/$search',
            )
          : Uri.parse('http://192.168.17.133:3001/api/products/products');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Add validation here
        final validProducts = data
            .where(
              (item) =>
                  item['product_id'] != null &&
                  item['name'] != null &&
                  item['price'] != null,
            )
            .toList();

        setState(() {
          products = validProducts
              .map((json) => Product.fromJson(json))
              .toList();
          filteredProducts = List.from(products);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
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

  Future<void> fetchUnits() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.17.133:3001/api/units/units'),
      );

      if (response.statusCode == 200) {
        setState(() {
          units = json.decode(response.body);
        });
      } else {
        throw Exception('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນຫົວໜ່ວຍໄດ້');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading units: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.17.133:3001/api/categories/categories'),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      } else {
        throw Exception('ບໍ່ສາມາດໂຫຼດຂໍ້ມູນປະເພດໄດ້');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.17.133:3001/api/suppliers/suppliers'),
      );

      if (response.statusCode == 200) {
        setState(() {
          suppliers = json.decode(response.body);
        });
      } else {
        throw Exception('ບສາມາດໂຫຼດຂໍ້ມູນຜູ້ສະໜອງໄດ້');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading suppliers: ${e.toString()}')),
      );
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.post(
        Uri.parse('http://192.168.17.133:3001/api/products/products'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock_quantity': product.stockQuantity,
          'unit_id': product.unitId,
          'category_id': product.categoryId,
          'supplier_id': product.supplierId,
        }),
      );

      if (response.statusCode == 200) {
        fetchProducts();
      } else {
        final resData = json.decode(response.body);
        String errorMsg = resData['message'] ?? 'ເພີ່ມບໍ່ສຳເລັດ';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        throw Exception(errorMsg); // เพื่อแจ้ง error ไปยัง dialog ด้วย
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.put(
        Uri.parse(
          'http://192.168.17.133:3001/api/products/products/${product.productId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },

        body: json.encode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock_quantity': product.stockQuantity,
          'unit_id': product.unitId,
          'category_id': product.categoryId,
          'supplier_id': product.supplierId,
        }),
      );

      if (response.statusCode == 200) {
        fetchProducts();
      } else {
        throw Exception('ແກ້ໄຂບໍ່ສຳເລັດ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      final response = await http.delete(
        Uri.parse(
          'http://192.168.17.133:3001/api/products/products/$productId',
        ),
        headers: {
          'X-User-ID': userId.toString(), // ส่ง user_id ไปกับ header
        },
      );

      if (response.statusCode == 200) {
        fetchProducts();
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

  // void _showAddEditProductDialog({Product? product}) {
  void _showAddEditProductDialog({Product? product}) {
    // final nameController = TextEditingController(text: product?.name ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    String? selectedUnit = product?.unitId?.toString();
    String? selectedCategory = product?.categoryId?.toString();
    String? selectedSupplier = product?.supplierId?.toString();

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
                            product == null ? Icons.add_box : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            product == null ? 'ເພີ່ມສິນຄ້າ' : 'ແກ້ໄຂສິນຄ້າ',
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
                      // Description
                      TextField(
                        controller: descriptionController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຄຳອະທິບາຍ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                      ),
                      SizedBox(height: 14),
                      // Price
                      TextField(
                        controller: priceController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ລາຄາ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      SizedBox(height: 14),
                      // Stock Quantity
                      TextField(
                        controller: stockController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຈຳນວນ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 14),
                      // Unit Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຫົວໜ່ວຍ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        dropdownColor: Color(0xFF0D0D2B),
                        items: units.map<DropdownMenuItem<String>>((unit) {
                          return DropdownMenuItem<String>(
                            value: unit['unit_id'].toString(),
                            child: Text(
                              unit['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedUnit = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 14),
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ປະເພດ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        dropdownColor: Color(0xFF0D0D2B),
                        items: categories.map<DropdownMenuItem<String>>((
                          category,
                        ) {
                          return DropdownMenuItem<String>(
                            value: category['category_id'].toString(),
                            child: Text(
                              category['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedCategory = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 14),
                      // Supplier Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedSupplier,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຜູ້ສະໜອງ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0D0D2B),
                        ),
                        items: suppliers.map<DropdownMenuItem<String>>((
                          supplier,
                        ) {
                          return DropdownMenuItem<String>(
                            value: supplier['supplier_id'].toString(),
                            child: Text(
                              supplier['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Color(0xFF0D0D2B),
                        onChanged: (String? newValue) {
                          setDialogState(() {
                            selectedSupplier = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 14),
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
                              } else if (priceController.text.trim().isEmpty) {
                                emptyField = 'ລາຄາ';
                              } else if (stockController.text.trim().isEmpty) {
                                emptyField = 'ຈຳນວນ';
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

                              final newProduct = Product(
                                productId: product?.productId ?? 0,
                                name: nameController.text,
                                description: descriptionController.text,
                                price:
                                    double.tryParse(priceController.text) ??
                                    0.0,
                                stockQuantity:
                                    int.tryParse(stockController.text) ?? 0,
                                unitId: selectedUnit != null
                                    ? int.parse(selectedUnit!)
                                    : null,
                                categoryId: selectedCategory != null
                                    ? int.parse(selectedCategory!)
                                    : null,
                                supplierId: selectedSupplier != null
                                    ? int.parse(selectedSupplier!)
                                    : null,
                                unitName: product?.unitName,
                                categoryName: product?.categoryName,
                                supplierName: product?.supplierName,
                                createdAt: product?.createdAt ?? DateTime.now(),
                              );

                              try {
                                if (product == null) {
                                  await addProduct(newProduct);
                                } else {
                                  await updateProduct(newProduct);
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
                                product == null ? 'ບັນທຶກ' : 'ບັນທຶກ',
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

  void _showDeleteConfirmationDialog(int productId) async {
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
        await deleteProduct(productId);
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
            Icon(Icons.shopping_bag, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຈັດການສິນຄ້າ',
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
            onPressed: () {
              fetchProducts();
              fetchUnits();
              fetchCategories();
              fetchSuppliers();
            },
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
                          labelText:
                              'ຄົ້ນຫາສິນຄ້າດ້ວຍ ຊື່, ຜູ້ສະໜອງ, ປະເພດ, ຫົວໜ່ວຍ, Bar code, ລາຄາ, ຈຳນວນ',
                          labelStyle: TextStyle(color: Colors.white),
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
                                fetchProducts(search: searchController.text),
                          ),
                        ),
                        onChanged: (value) => fetchProducts(search: value),
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
                    : filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          searchController.text.isEmpty
                              ? 'ກຳລັງໂຫຼດຂໍ້ມູນ...'
                              : 'ບໍ່ພົບສິນຄ້າ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            color: const Color(0xFF23235B),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ExpansionTile(
                              collapsedBackgroundColor: Color(0xFF23235B),
                              backgroundColor: Color(0xFF23235B),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'ລາຄາ: ${(product.price * 1.1).toStringAsFixed(2)} ກີບ | ຈຳນວນ: ${product.stockQuantity} ${product.unitName ?? ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
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
                                    onPressed: () => _showAddEditProductDialog(
                                      product: product,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(
                                          product.productId,
                                        ),
                                  ),
                                  // ใส่ไอคอนลูกศรปกติของ ExpansionTile จะขึ้นเองครับ
                                ],
                              ),
                              children: [
                                if (product.barcode != null &&
                                    product.barcode!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: BarcodeWidget(
                                      barcode: Barcode.ean13(),
                                      data: product.barcode!,
                                      width: 200,
                                      height: 100,
                                      drawText: true,
                                      backgroundColor: Colors.white,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
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
          'ເພີ່ມສິນຄ້າ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddEditProductDialog(),
        elevation: 6,
      ),
    );
  }
}
