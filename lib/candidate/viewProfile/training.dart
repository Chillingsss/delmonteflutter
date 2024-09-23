import 'package:flutter/material.dart';

class Training extends StatelessWidget {
  final List<dynamic> data;

  const Training({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Training Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0A6338),
        iconTheme: IconThemeData(color: Colors.white),
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
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/images/$imageName',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 30),
                      Text(
                        'Error loading image',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                    ],
                  );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Remove the _checkImageAvailability method as it's no longer needed
}
