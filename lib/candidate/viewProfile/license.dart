import 'package:flutter/material.dart';

class License extends StatelessWidget {
  final dynamic licenses;

  const License({super.key, required this.licenses});

  @override
  Widget build(BuildContext context) {
    List<dynamic> licenseList = [];
    if (licenses is List) {
      licenseList = licenses;
    } else if (licenses is Map && licenses.containsKey('license')) {
      licenseList = licenses['license'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'License Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: licenseList.isEmpty
            ? const Center(child: Text('No license information available'))
            : ListView.builder(
                itemCount: licenseList.length,
                itemBuilder: (context, index) {
                  final license = licenseList[index];
                  return _buildLicenseItem(license);
                },
              ),
      ),
    );
  }

  Widget _buildLicenseItem(dynamic license) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
                'License', license['license_master_name']?.toString() ?? 'N/A'),
            _buildInfoItem(
                'Type', license['license_type_name']?.toString() ?? 'N/A'),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A6338),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
