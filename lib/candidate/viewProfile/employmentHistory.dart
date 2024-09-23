import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmploymentHistory extends StatelessWidget {
  final dynamic data;

  const EmploymentHistory({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> employmentHistory;

    if (data == null) {
      employmentHistory = [];
    } else if (data is List) {
      employmentHistory = data;
    } else if (data is Map && data.containsKey('employmentHistory')) {
      employmentHistory = data['employmentHistory'] as List<dynamic>;
    } else {
      employmentHistory = [data];
    }

    if (employmentHistory.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Employment History',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0A6338),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text('No employment history available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employment History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0A6338),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: employmentHistory.length,
        itemBuilder: (context, index) {
          final job = employmentHistory[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
                'Position', job['empH_positionName']?.toString() ?? 'N/A'),
            _buildInfoItem(
                'Company', job['empH_companyName']?.toString() ?? 'N/A'),
            _buildInfoItem(
                'Start Date', _formatDate(job['empH_startdate']?.toString())),
            _buildInfoItem(
                'End Date', _formatDate(job['empH_enddate']?.toString())),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
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
