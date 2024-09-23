import 'package:flutter/material.dart';

class Knowledge extends StatelessWidget {
  final List<dynamic> knowledgeList;

  const Knowledge({super.key, required this.knowledgeList});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: const Color(0xFF0A6338),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A6338),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Knowledge & Expertise',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Areas of Expertise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A6338),
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildKnowledgeList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeList(BuildContext context) {
    return ListView.separated(
      itemCount: knowledgeList.length,
      separatorBuilder: (context, index) => Divider(
        thickness: 1.2,
        color: Colors.grey[300],
        height: 32,
      ),
      itemBuilder: (context, index) =>
          _buildKnowledgeCard(context, knowledgeList[index]),
    );
  }

  Widget _buildKnowledgeCard(BuildContext context, dynamic knowledge) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.bolt,
                color: Color(0xFF0A6338), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    knowledge['knowledge_name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
