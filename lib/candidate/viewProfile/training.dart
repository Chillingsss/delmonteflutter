import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Training extends StatelessWidget {
  final List<dynamic> data;

  const Training({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Training Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final training = data[index];
            return _buildTrainingItem(
              context,
              training['perT_name'],
              training['training_image'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrainingItem(
      BuildContext context, String trainingName, String imageName) {
    final imageUrl =
        'http://192.168.237.130/php-delmonte/api/uploads/$imageName';

    print('Loading image from URL: $imageUrl'); // Add this debug print

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showFullScreenImage(context, imageName),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    print('Stack trace: $stackTrace'); // Add this debug print
                    return Icon(Icons.error, color: Colors.red, size: 30);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainingName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Image: $imageName',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageName) {
    final imageUrl =
        'http://192.168.237.130/php-delmonte/api/uploads/$imageName'; // Update this URL

    print(
        'Loading full-screen image from URL: $imageUrl'); // Add this debug print

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading full-screen image: $error');
                    print('Stack trace: $stackTrace'); // Add this debug print
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 50),
                        SizedBox(height: 16),
                        Text(
                          'Error loading image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
