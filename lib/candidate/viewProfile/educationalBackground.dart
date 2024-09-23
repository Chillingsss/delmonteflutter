import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EducationalBackground extends StatelessWidget {
  final dynamic data;

  const EducationalBackground({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null || (data is List && data.isEmpty)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Educational Background',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0A6338),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text('No educational background available.'),
        ),
      );
    }

    final List<dynamic> educationalBackgrounds = data is List ? data : [data];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Educational Background',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0A6338),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: educationalBackgrounds.length,
        itemBuilder: (context, index) {
          final background = educationalBackgrounds[index];
          return _buildEducationCard(background);
        },
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> background) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Course', background['courses_name']),
            _buildInfoItem('Institution', background['institution_name']),
            _buildInfoItem('Graduation Date',
                _formatDate(background['educ_dategraduate'])),
            _buildInfoItem('Category', background['course_categoryName']),
            _buildInfoItem('Type', background['crs_type_name']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A6338),
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMMM d, y').format(date);
  }
}
