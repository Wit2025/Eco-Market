import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRate {
  final int id;
  final String currencyCode;
  final double rate;
  final String unit;
  final DateTime? createdAt;

  ExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.rate,
    required this.unit,
    this.createdAt,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      id: json['id'],
      currencyCode: json['currency_code'],
      rate: double.parse(json['rate'].toString()),
      unit: json['unit'] ?? 'LAK',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'currency_code': currencyCode, 'rate': rate, 'unit': unit};
  }
}

class ExchangeRateManagementPage extends StatefulWidget {
  @override
  _ExchangeRateManagementPageState createState() =>
      _ExchangeRateManagementPageState();
}

class _ExchangeRateManagementPageState
    extends State<ExchangeRateManagementPage> {
  List<ExchangeRate> exchangeRates = [];
  List<ExchangeRate> filteredRates = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final String baseUrl = 'http://192.168.17.133:3001/api/exchanges';

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates({String? search}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          exchangeRates = data
              .map((json) => ExchangeRate.fromJson(json))
              .toList();
          filteredRates = List.from(exchangeRates);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exchange rates');
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

  Future<void> addExchangeRate(ExchangeRate rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(),
        },
        body: json.encode(rate.toJson()),
      );

      if (response.statusCode == 200) {
        fetchExchangeRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ເພີ່ມສຳເລັດ"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final resData = json.decode(response.body);
        throw Exception(resData['message'] ?? 'Failed to add exchange rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  Future<void> updateExchangeRate(ExchangeRate rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await http.put(
        Uri.parse('$baseUrl/${rate.id}'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(),
        },
        body: json.encode(rate.toJson()),
      );

      if (response.statusCode == 200) {
        fetchExchangeRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ແກ້ໄຂສຳເລັດ"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update exchange rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteExchangeRate(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'X-User-ID': userId.toString()},
      );

      if (response.statusCode == 200) {
        fetchExchangeRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ລົບສຳເລັດ"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final resData = json.decode(response.body);
        String message = resData['message'] ?? 'Failed to delete';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      rethrow;
    }
  }

  void _showAddEditExchangeRateDialog({ExchangeRate? rate}) {
    final currencyCodeController = TextEditingController(
      text: rate?.currencyCode ?? '',
    );
    final rateController = TextEditingController(
      text: rate?.rate.toString() ?? '',
    );
    final unitController = TextEditingController(text: rate?.unit ?? 'LAK');

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                            rate == null ? Icons.add : Icons.edit,
                            color: Colors.teal,
                            size: 32,
                          ),
                          SizedBox(width: 10),
                          Text(
                            rate == null
                                ? 'ເພີ່ມອັດຕາແລກປ່ຽນ'
                                : 'ແກ້ໄຂອັດຕາແລກປ່ຽນ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),

                      // Currency Code field
                      TextField(
                        controller: currencyCodeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ລະຫັດສະກຸນເງິນ (USD, THB, etc.)',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1A1A3A),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Exchange Rate field
                      TextField(
                        controller: rateController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ອັດຕາແລກປ່ຽນ',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1A1A3A),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Unit field
                      TextField(
                        controller: unitController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ຫົວໜ່ວຍ (ຄ່າເລີ່ມຕົ້ນ: LAK)',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1A1A3A),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
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
                              // Validation
                              if (currencyCodeController.text.isEmpty) {
                                _showErrorDialog('ກະລຸນາປ້ອນລະຫັດສະກຸນເງິນ');
                                return;
                              }
                              if (rateController.text.isEmpty) {
                                _showErrorDialog('ກະລຸນາປ້ອນອັດຕາແລກປ່ຽນ');
                                return;
                              }

                              final newRate = ExchangeRate(
                                id: rate?.id ?? 0,
                                currencyCode: currencyCodeController.text
                                    .toUpperCase(),
                                rate: double.tryParse(rateController.text) ?? 0,
                                unit: unitController.text.isNotEmpty
                                    ? unitController.text
                                    : 'LAK',
                              );

                              try {
                                if (rate == null) {
                                  await addExchangeRate(newRate);
                                } else {
                                  await updateExchangeRate(newRate);
                                }
                                Navigator.pop(context);
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
                                rate == null ? 'ບັນທຶກ' : 'ອັບເດດ',
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent.shade100, Colors.red.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade200.withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
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

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _showDeleteConfirmationDialog(int id) async {
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
                'ທ່ານແນ່ໃຈບໍ່ວ່າຈະລົບອັດຕາແລກປ່ຽນນີ້?',
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
        await deleteExchangeRate(id);
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
            Icon(Icons.currency_exchange, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ຈັດການອັດຕາແລກປ່ຽນ',
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
            onPressed: () => fetchExchangeRates(),
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
                          labelText: 'ຄົ້ນຫາດ້ວຍລະຫັດສະກຸນເງິນ',
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
                            onPressed: () {
                              // Implement search if needed
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredRates = exchangeRates
                                .where(
                                  (rate) => rate.currencyCode
                                      .toLowerCase()
                                      .contains(value.toLowerCase()),
                                )
                                .toList();
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
                    : filteredRates.isEmpty
                    ? Center(
                        child: Text(
                          'ບໍ່ມີຂໍ້ມູນອັດຕາແລກປ່ຽນ',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRates.length,
                        itemBuilder: (context, index) {
                          final rate = filteredRates[index];
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
                                  rate.currencyCode,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '${rate.rate} ${rate.unit}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: rate.createdAt != null
                                  ? Text(
                                      'ວັນທີ: ${rate.createdAt!.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(color: Colors.white70),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () =>
                                        _showAddEditExchangeRateDialog(
                                          rate: rate,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmationDialog(rate.id),
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
        onPressed: () => _showAddEditExchangeRateDialog(),
        tooltip: 'ເພີ່ມອັດຕາແລກປ່ຽນໃໝ່',
        elevation: 6,
      ),
    );
  }
}
