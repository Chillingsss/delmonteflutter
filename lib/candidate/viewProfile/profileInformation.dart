import 'package:flutter/material.dart';

class ProfileInformation extends StatelessWidget {
  final dynamic data;

  const ProfileInformation({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If data is null or empty, show a message
    if (data == null ||
        (data is Map && data.isEmpty) ||
        (data is List && data.isEmpty)) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile Information'),
          backgroundColor: Color(0xFF0A6338),
        ),
        body: Center(
          child: Text('No profile information available.'),
        ),
      );
    }

    // If data is a List, use the first item
    final Map<String, dynamic> profileData = data is List ? data[0] : data;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Information'),
        backgroundColor: Color(0xFF0A6338),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Name',
                '${profileData['cand_firstname'] ?? ''} ${profileData['cand_lastname'] ?? ''}'),
            _buildInfoItem('Email', profileData['cand_email'] ?? ''),
            _buildInfoItem('Phone', profileData['cand_contactNo'] ?? ''),
            _buildInfoItem('Address', profileData['cand_address'] ?? ''),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A6338),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
