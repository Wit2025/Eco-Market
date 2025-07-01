import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

final ValueNotifier<List<dynamic>> globalActivities = ValueNotifier([]);

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  bool _isLoadingActivities = false;
  String? _activityError;
  String _selectedPeriod = '1m'; // Default to 1 month

  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  final int _limit = 50;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchActivities(period: _selectedPeriod);
  }

  void _scrollListener() {}

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities({
    String? period,
    bool isLoadMore = false,
    bool forceRefresh = false,
  }) async {
    if ((isLoadMore && _isLoadingMore) || (!isLoadMore && _isLoadingActivities))
      return;
    if (isLoadMore && !_hasMore) return;

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoadingActivities = true;
        _activityError = null;
        _page = 1;
        _hasMore = true;
      }
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.17.133:3001/api/activities/activities?period=${period ?? _selectedPeriod}&page=$_page&limit=$_limit',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List newActivities = data['data'];
        final bool hasMore = data['hasMore'] ?? false;

        if (newActivities.isNotEmpty) {
          setState(() {
            if (isLoadMore) {
              globalActivities.value = [
                ...globalActivities.value,
                ...newActivities,
              ];
            } else {
              globalActivities.value = newActivities;
            }
            _hasMore = hasMore;
            _page++;
          });
        } else {
          setState(() {
            _hasMore = false;
            if (isLoadMore) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('ບໍ່ມີຂໍ້ມູນເພີ່ມເຕີມ')));
            }
          });
        }
      } else {
        setState(() {
          _activityError = 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນກິດຈະກຳ';
        });
      }
    } catch (e) {
      setState(() {
        _activityError = 'ມີຂໍ້ຜິດພາດໃນການເຊື່ອມຕໍ່: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingActivities = false;
        _isLoadingMore = false;
      });
    }
  }

  String _getTableDisplayName(String tableName) {
    const tableNames = {
      'categories': 'ໝວດໝູ່',
      'products': 'ສິນຄ້າ',
      'suppliers': 'ຜູ້ສະໜອງ',
      'employees': 'ພະນັກງານ',
      'units': 'ຫົວໜ່ວຍ',
      'customers': 'ລູກຄ້າ',
      'users': 'ຜູ້ໃຊ້',
      'orders': 'ສັ່ງຊື້',
    };
    return tableNames[tableName] ?? tableName;
  }

  String _getActionDisplay(String action) {
    const actions = {'create': 'ເພີ່ມໃໝ່', 'update': 'ແກ້ໄຂ', 'delete': 'ລຶບ'};
    return actions[action] ?? action;
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getActivityName(dynamic activity) {
    if (activity['action'] == 'delete') {
      return activity['old_values']?['name'] ?? 'ID ${activity['id']}';
    }
    return activity['new_values']?['name'] ?? 'ID ${activity['id']}';
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _getFieldDisplayName(String field) {
    const fieldNames = {
      'name': 'ຊື່',
      'description': 'ຄຳອະທິບາຍ',
      'phone': 'ເບີໂທ',
      'email': 'ອີເມວ',
      'address': 'ທີ່ຢູ່',
      'created_at': 'ວັນທີສ້າງ',
      'updated_at': 'ວັນທີແກ້ໄຂ',
      'category_id': 'ລະຫັດໝວດໝູ່',
      'supplier_id': 'ລະຫັດຜູ້ສະໜອງ',
      'unit_id': 'ລະຫັດຫົວໜ່ວຍ',
      'product_id': 'ລະຫັດສິນຄ້າ',
      'price': 'ລາຄາ',
      'stock_quantity': 'ຈຳນວນສິນຄ້າ',
      'barcode': 'ບາໂຄດ',
      'employee_id': 'ລະຫັດພະນັກງານ',
      'lastname': 'ນາມສະກຸນ',
      'role': 'ສິດທິ',
      'id': 'ລະຫັດຜູ້ໃຊ້',
      'username': 'ຊື່ຜູ້ໃຊ້',
      'password': 'ລະຫັດຜ່ານ',
      'customer_id': 'ລະຫັດລູກຄ້າ',
      'order_id': 'ລະຫັດຄຳສັ່ງຊື້',
      'quantity': 'ຈຳນວນ',
      'total_price': 'ລາຄາລວມ',
      'status': 'ສະຖານະ',
    };
    return fieldNames[field] ?? field;
  }

  String _getPeriodDisplay(String period) {
    switch (period) {
      case '1m':
        return '1 ເດືອນ';
      case '3m':
        return '3 ເດືອນ';
      case '6m':
        return '6 ເດືອນ';
      default:
        return '1 ເດືອນ';
    }
  }

  Widget _buildActivityCard(dynamic activity) {
    bool isExpanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_getTableDisplayName(activity['table'])}: ${_getActivityName(activity)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getActionColor(activity['action']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getActionDisplay(activity['action']),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatTimestamp(activity['timestamp']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (activity['performer'] != null &&
                            activity['performer']['username'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '${activity['performer']['username']} (${activity['performer']['name'] ?? "ບໍ່ມີຂໍ້ມູນ"})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        if (activity['user_ip'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'IP: ${activity['user_ip']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        if (activity['user_agent'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.computer,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                _parseUserAgent(activity['user_agent']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (activity['action'] == 'update' &&
                        activity['changed_fields'] != null &&
                        activity['changed_fields'].isNotEmpty)
                      _buildChangesList(activity),
                    if (activity['action'] == 'delete')
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'ຂໍ້ມູນທີ່ຖືກລຶບ: ${_getActivityName(activity)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _parseUserAgent(String userAgent) {
    if (userAgent.isEmpty) return 'Unknown device';

    String browser = 'Browser: ';
    if (userAgent.contains('Chrome')) {
      browser += 'Chrome';
    } else if (userAgent.contains('Firefox')) {
      browser += 'Firefox';
    } else if (userAgent.contains('Safari')) {
      browser += 'Safari';
    } else if (userAgent.contains('Edge')) {
      browser += 'Edge';
    } else {
      browser += 'Other';
    }

    String os = ' | OS: ';
    if (userAgent.contains('Windows')) {
      os += 'Windows';
    } else if (userAgent.contains('Mac')) {
      os += 'Mac';
    } else if (userAgent.contains('Linux')) {
      os += 'Linux';
    } else if (userAgent.contains('Android')) {
      os += 'Android';
    } else if (userAgent.contains('iOS')) {
      os += 'iOS';
    } else {
      os += 'Other';
    }

    return browser + os;
  }

  Widget _buildChangesList(dynamic activity) {
    final oldValues = activity['old_values'] ?? {};
    final newValues = activity['new_values'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'ຂໍ້ມູນທີ່ແກ້ໄຂ:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: (activity['changed_fields'] as List).map<Widget>((field) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        _getFieldDisplayName(field),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            TextSpan(
                              text: '${oldValues[field] ?? 'ບໍ່ມີ'}',
                              style: TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            TextSpan(text: ' → '),
                            TextSpan(
                              text: '${newValues[field] ?? 'ບໍ່ມີ'}',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.monitor, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ກິດຈະກຳຫຼ້າສຸດ',
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
            onPressed: () =>
                _fetchActivities(period: _selectedPeriod, forceRefresh: true),
          ),
        ],
      ),
      body: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: globalActivities,
              builder: (context, activities, child) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23235B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ກິດຈະກຳຫຼ້າສຸດ (${_getPeriodDisplay(_selectedPeriod)})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'ໄລຍະເວລາ: ',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedPeriod,
                                dropdownColor: const Color(0xFF23235B),
                                style: TextStyle(color: Colors.white),
                                items: [
                                  DropdownMenuItem(
                                    value: '1m',
                                    child: Text('1 ເດືອນ'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3m',
                                    child: Text('3 ເດືອນ'),
                                  ),
                                  DropdownMenuItem(
                                    value: '6m',
                                    child: Text('6 ເດືອນ'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedPeriod = newValue;
                                    });
                                    _fetchActivities(period: newValue);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (_isLoadingActivities && !_isLoadingMore)
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.purpleAccent,
                          ),
                        )
                      else if (_activityError != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              _activityError!,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else if (activities.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'ບໍ່ມີກິດຈະກຳລ່າສຸດ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: RefreshIndicator(
                            color: Colors.purpleAccent,
                            onRefresh: () => _fetchActivities(
                              period: _selectedPeriod,
                              forceRefresh: true,
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: activities.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == activities.length && _hasMore) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purpleAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (!_isLoadingMore) {
                                            _fetchActivities(isLoadMore: true);
                                          }
                                        },
                                        child: _isLoadingMore
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'ໂຫຼດເພີ່ມເຕີມ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }
                                return _buildActivityCard(activities[index]);
                              },
                            ),
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
    );
  }
}
