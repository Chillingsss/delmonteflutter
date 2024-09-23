import 'package:flutter/material.dart';

class Skills extends StatelessWidget {
  final List<dynamic> data;

  const Skills({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<String> skills = _parseSkills(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skills',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: skills.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSkillItem(skills[index]),
                        childCount: skills.length,
                      ),
                    )
                  : const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'No skills found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ),
            ),
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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF0A6338),
          child: Icon(Icons.star, color: Colors.white, size: 20),
        ),
        title: Text(
          skill,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
