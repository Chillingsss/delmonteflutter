import 'package:flutter/material.dart';

class JobDetails extends StatelessWidget {
  final Map<String, dynamic> jobDetails;

  const JobDetails({Key? key, required this.jobDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Title: ${jobDetails['jobM_title']}'),
            const SizedBox(height: 10),
            Text('Description: ${jobDetails['jobM_description']}'),
            const SizedBox(height: 10),
            Text('Duties:'),
            ...jobDetails['duties_text'].split('|').map((duty) => Text('• $duty')),
            const SizedBox(height: 10),
            Text('Education: ${jobDetails['jeduc_text']}'),
            const SizedBox(height: 10),
            Text('Work Responsibilities: ${jobDetails['jwork_responsibilities']}'),
            const SizedBox(height: 10),
            Text('Work Duration: ${jobDetails['jwork_duration']}'),
            const SizedBox(height: 10),
            Text('Knowledge: ${jobDetails['jknow_text']}'),
            const SizedBox(height: 10),
            Text('Knowledge Name: ${jobDetails['knowledge_name']}'),
            const SizedBox(height: 10),
            Text('Skills: ${jobDetails['jskills_text']}'),
            const SizedBox(height: 10),
            Text('Training: ${jobDetails['jtrng_text']}'),
            const SizedBox(height: 10),
            Text('Total Applied: ${jobDetails['Total_Applied']}'),
          ],
        ),
      ),
    );
  }
}
