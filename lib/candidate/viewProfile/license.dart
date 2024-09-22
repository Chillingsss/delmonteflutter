import 'package:flutter/material.dart';

class License extends StatelessWidget {
  final Map<String, dynamic> data;

  const License({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            _buildInfoItem(
                'Name', data['cand_fname'] + ' ' + data['cand_lname']),
            _buildInfoItem('Email', data['cand_email']),
            _buildInfoItem('Phone', data['cand_contactno']),
            _buildInfoItem('Address', data['cand_address']),
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
