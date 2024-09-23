import 'package:flutter/material.dart';

class ProfileInformation extends StatelessWidget {
  final dynamic data;

  const ProfileInformation({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // If data is null or empty, show a message
    if (data == null ||
        (data is Map && data.isEmpty) ||
        (data is List && data.isEmpty)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Information'),
          backgroundColor: const Color(0xFF0A6338),
        ),
        body: const Center(
          child: Text('No profile information available.'),
        ),
      );
    }

    // If data is a List, use the first item
    final Map<String, dynamic> profileData = data is List ? data[0] : data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Information',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Personal Information', [
              _buildInfoItem('Name',
                  '${profileData['cand_firstname'] ?? ''} ${profileData['cand_middlename'] ?? ''} ${profileData['cand_lastname'] ?? ''}'),
              _buildInfoItem(
                  'Date of Birth', profileData['cand_dateofBirth'] ?? ''),
              _buildInfoItem('Sex', profileData['cand_sex'] ?? ''),
            ]),
            const SizedBox(height: 16),
            _buildSection('Contact Information', [
              _buildInfoItem('Email', profileData['cand_email'] ?? ''),
              _buildInfoItem(
                  'Alternate Email', profileData['cand_alternateEmail'] ?? ''),
              _buildInfoItem('Phone', profileData['cand_contactNo'] ?? ''),
              _buildInfoItem('Alternate Phone',
                  profileData['cand_alternatecontactNo'] ?? ''),
            ]),
            const SizedBox(height: 16),
            _buildSection('Address', [
              _buildInfoItem(
                  'Present Address', profileData['cand_presentAddress'] ?? ''),
              _buildInfoItem('Permanent Address',
                  profileData['cand_permanentAddress'] ?? ''),
            ]),
            const SizedBox(height: 16),
            _buildSection('Government IDs', [
              _buildInfoItem('SSS Number', profileData['cand_sssNo'] ?? ''),
              _buildInfoItem('TIN Number', profileData['cand_tinNo'] ?? ''),
              _buildInfoItem(
                  'PhilHealth Number', profileData['cand_philhealthNo'] ?? ''),
              _buildInfoItem(
                  'Pag-IBIG Number', profileData['cand_pagibigNo'] ?? ''),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A6338),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
