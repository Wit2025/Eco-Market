import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _image;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  List<Map<String, dynamic>> _uploadedImages = [];

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // สำหรับเว็บ
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      } else {
        // สำหรับมือถือ
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> uploadImage() async {
    if ((_image == null && _imageBytes == null) || _isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      var uri = Uri.parse("http://192.168.17.133:3001/api/images");
      var request = http.MultipartRequest('POST', uri);

      // สำหรับเว็บ
      if (kIsWeb && _imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: MediaType('image', 'jpeg'), // เพิ่ม content type
          ),
        );
      }
      // สำหรับมือถือ
      else if (!kIsWeb && _image != null) {
        var fileExtension = _image!.path.split('.').last.toLowerCase();
        var contentType = fileExtension == 'png'
            ? MediaType('image', 'png')
            : fileExtension == 'gif'
            ? MediaType('image', 'gif')
            : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
            contentType: contentType, // เพิ่ม content type ตามประเภทไฟล์
          ),
        );
      }

      // เพิ่ม headers หากจำเป็น
      request.headers['Accept'] = 'application/json';

      print('ກຳລັງອັພໂຫຼດຮູບ...');
      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('ການຕອບກັບຈາກເຊິບເວີ: $responseData');

      if (response.statusCode == 201) {
        try {
          final newImage = json.decode(responseData);
          if (mounted) {
            setState(() {
              _uploadedImages.insert(0, newImage['image']);
              _image = null;
              _imageBytes = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 26,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "ອັບໂຫຼດຮູບພາບສຳເລັດ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.indigo,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('ເກີດຂໍ້ຜິດພາດ: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ເກີດຂໍ້ຜິດພາດໃນການປະມວນຜົນຂໍ້ມູນ")),
            );
          }
        }
      } else {
        try {
          final errorResponse = json.decode(responseData);
          final errorMsg = errorResponse['message'] ?? 'ອັພໂຫຼດຮູບລົ້ມເຫຼວ';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$errorMsg (${response.statusCode})")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("ລົ້ມເຫຼວ: ${response.statusCode}")),
            );
          }
        }
      }
    } catch (e) {
      print("ເກີດຂໍ້ຜິດພາດໃນການອັພໂຫຼດຮູບ: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ເກີດຂໍ້ຜິດພາດ: ${e is SocketException ? 'ການເຊື່ອຕໍ່ລົ້ມເລວ' : e.toString()}",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> deleteImage(int id, String imagePath) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.17.133:3001/api/images/$id"),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _uploadedImages.removeWhere((img) => img['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.redAccent, size: 26),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "ລົບຮູບສຳເລັດ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("ລົບຮູບລົ້ມເຫຼວ: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ເກີດຂໍ້ຜິດພາດ: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.17.133:3001/api/images"),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _uploadedImages = List<Map<String, dynamic>>.from(
            json.decode(response.body),
          );
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ບໍ່ສາມາດອັບໂຫຼດຮູບ: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Widget _buildImagePreview() {
    if ((_image == null && _imageBytes == null)) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: Center(child: Text("ຍັງບໍ່ໄດ້ເລືອກຮູບ")),
      );
    }

    if (kIsWeb) {
      return Image.memory(
        _imageBytes!,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      return Image.file(
        _image!,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[300]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "ບໍ່ສາມາດໂຫຼດຮູບ",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(0xFF2D3250);
    final accentColor = Color(0xFFF9B17A);

    // โคตรสวย: ไล่เฉดสีแบบ glassmorphism + gradient หลายสี
    final bgGradient = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFf8ffae),
            Color(0xFF43cea2),
            Color(0xFF185a9d),
            Color(0xFFf953c6),
            Color(0xFFb91d73),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 0.8, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          backgroundBlendMode: BlendMode.overlay,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "ອັບໂຫຼດຮູບພາບ",
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: Stack(
        children: [
          bgGradient,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // ส่วนอัพโหลดรูปใหม่
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.85),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildImagePreview(),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                elevation: 3,
                              ),
                              onPressed: pickImage,
                              icon: Icon(Icons.image),
                              label: Text(
                                "ເລືອກຮູບພາບ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                elevation: 3,
                              ),
                              onPressed:
                                  (_image == null && _imageBytes == null) ||
                                      _isUploading
                                  ? null
                                  : uploadImage,
                              icon: _isUploading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.cloud_upload_rounded),
                              label: Text(
                                "ອັບໂຫຼດ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ส่วนแสดงรูปที่อัพโหลดแล้ว
                SizedBox(height: 32),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      color: themeColor,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "ຮູບພາບທີ່ອັບໂຫຼດແລ້ວ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                _uploadedImages.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "ຍັງບໍ່ມີຮູບພາບທີ່ອັບໂຫຼດ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _uploadedImages.length,
                        itemBuilder: (context, index) {
                          final image = _uploadedImages[index];
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Hero(
                                    tag: "image_${image['id']}",
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.network(
                                                "http://192.168.17.133:3001${image['path']}",
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) =>
                                                        _buildErrorPlaceholder(),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        "http://192.168.17.133:3001${image['path']}",
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: accentColor,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                        size: 40,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "ບໍ່ສາມາດໂຫຼດຮູບ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => deleteImage(
                                        image['id'],
                                        image['path'],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
