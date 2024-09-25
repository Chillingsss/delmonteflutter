import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'update_educbac.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EducationalBackground extends StatefulWidget {
  final dynamic data;
  final int candId;

  const EducationalBackground({
    Key? key,
    required this.data,
    required this.candId,
  }) : super(key: key);

  @override
  _EducationalBackgroundState createState() => _EducationalBackgroundState();
}

class _EducationalBackgroundState extends State<EducationalBackground> {
  Map<String, dynamic> profile = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    const String url = "http://localhost/php-delmonte/api/users.php";

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('cand_id');

    Map<String, dynamic> jsonData = {
      'cand_id': userId,
    };

    Map<String, dynamic> body = {
      'operation': 'getCandidateProfile',
      'json': json.encode(jsonData),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          profile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || (widget.data is List && widget.data.isEmpty)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Educational Background',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0A6338),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('No educational background available.'),
        ),
      );
    }

    final List<dynamic> educationalBackgrounds = widget.data is List ? widget.data : [widget.data];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Educational Background',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: educationalBackgrounds.length,
        itemBuilder: (context, index) {
          final background = educationalBackgrounds[index];
          return _buildEducationCard(context, background);
        },
      ),
    );
  }

  Widget _buildEducationCard(
      BuildContext context, Map<String, dynamic> background) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Course',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A6338),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEducBacPage(
                          data: background,
                          // Pass educ_back_id
                          candId: widget.candId.toString(), 
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              background['courses_name'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12.0),
            _buildInfoItem('Institution', background['institution_name']),
            const SizedBox(height: 12.0),
            _buildInfoItem('Graduation Date',
                _formatDate(background['educ_dategraduate'])),
            const SizedBox(height: 12.0),
            _buildInfoItem('Category', background['course_categoryName']),
            const SizedBox(height: 12.0),
            _buildInfoItem('Type', background['crs_type_name']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A6338),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMMM d, y').format(date);
  }
}
