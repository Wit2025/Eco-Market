import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final List<Map<String, dynamic>> activities = [
    {
      'title': 'ເບິ່ງວີດີໂອ 5 ນາທີ',
      'description': 'ຮັບ 10 ຄະແນນຫຼັງເບິ່ງວີດີໂອຈົບ',
      'icon': Icons.video_library,
      'color': Colors.purpleAccent,
    },
    {
      'title': 'ຕອບຄຳຖາມແບບສອບຖາມ',
      'description': 'ຮັບ 20 ຄະແນນເມື່ອເຮັດແບບສອບຖາມຄົບ',
      'icon': Icons.quiz,
      'color': Colors.orangeAccent,
    },
    {
      'title': 'ແຊລິ້ງໃຫ້ໝູ່',
      'description': 'ຮັບ 50 ຄະແນນເມື່ອເພື່ອນລົງທະບຽນສຳເລັດ',
      'icon': Icons.share,
      'color': Colors.lightBlueAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('ກິດຈະກຳ'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activity['color'].withOpacity(0.85),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: activity['color'],
                    child: Icon(
                      activity['icon'],
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    activity['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      activity['description'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activity['color'],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _performActivity(activity['title']);
                    },
                    child: const Text('ເຮັດກິດຈະກຳ'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _performActivity(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('ສຳເລັດ!', style: TextStyle(color: Colors.deepPurple)),
        content: Text('ເຈົ້າໄດ້ "$title" ສຳເລັດຮຽບຮ້ອຍ'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ຕົກລົງ',
                style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
