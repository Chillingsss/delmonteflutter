import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Training extends StatelessWidget {
  final List<dynamic> data;

  const Training({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Information'),
        backgroundColor: Color(0xFF0A6338),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final training = data[index];
            return _buildTrainingItem(
              training['perT_name'],
              training['training_image'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrainingItem(String trainingName, String imageName) {
    final imageUrl = 'http://localhost/php-delmonte/api/uploads/$imageName';
    final checkUrl =
        'http://localhost/php-delmonte/api/check_image.php?image_name=$imageName';

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              child: FutureBuilder<bool>(
                future: _checkImageAvailability(checkUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == true) {
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                Text('Loading...',
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          print('Stack trace: $stackTrace');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 30),
                              Text(
                                'Error: ${error.toString()}',
                                style:
                                    TextStyle(fontSize: 8, color: Colors.red),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 40);
                    }
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainingName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Image: $imageName',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  FutureBuilder<bool>(
                    future: _checkImageAvailability(checkUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image exists: ${snapshot.data}',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                            Text(
                              'Image URL: $imageUrl',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                          ],
                        );
                      }
                      return Text('Checking image...',
                          style: TextStyle(fontSize: 10, color: Colors.grey));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkImageAvailability(String checkUrl) async {
    try {
      final response = await http.get(Uri.parse(checkUrl));
      print('Check URL response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Image check data: $data');
        return data['exists'] ?? false;
      } else {
        print('Image check failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking image availability: $e');
    }
    return false;
  }
}
