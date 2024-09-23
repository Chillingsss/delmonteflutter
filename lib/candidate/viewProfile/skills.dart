import 'package:flutter/material.dart';

class Skills extends StatelessWidget {
  final List<dynamic> data;

  const Skills({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Full data: $data'); // Print the entire data object
    print('Type of data: ${data.runtimeType}');

    List<String> skills = _parseSkills(data);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skills',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0A6338),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A6338),
              ),
            ),
            SizedBox(height: 16),
            if (skills.isNotEmpty)
              ...skills.map((skill) => _buildSkillItem(skill))
            else
              Text('No skills found', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  List<String> _parseSkills(List<dynamic> skillsData) {
    return skillsData
        .map((item) => item['perS_name'] as String)
        .where((skill) => skill.isNotEmpty)
        .toList();
  }

  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF0A6338)),
          SizedBox(width: 8),
          Text(
            skill,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
