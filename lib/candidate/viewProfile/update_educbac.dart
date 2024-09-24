import 'package:delmonteflutter/candidate/notficationService.dart';
import 'package:delmonteflutter/candidate/viewProfile/viewProfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the viewProfile.dart file

class UpdateEducBacPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String candId;

  const UpdateEducBacPage({
    super.key,
    required this.data,
    required this.candId,
  });

  @override
  _UpdateEducBacPageState createState() => _UpdateEducBacPageState();
}

class _UpdateEducBacPageState extends State<UpdateEducBacPage> {
  List<dynamic> institutions = [];
  List<dynamic> courses = [];
  List<dynamic> courseTypes = [];
  List<dynamic> courseCategories = [];

  Map<String, dynamic> profile = {};
  bool isLoading = true;

  String? selectedInstitution;
  String? selectedCourse;
  String? selectedCourseType;
  String? selectedCourseCategory;

  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    fetchData();
    _dateController.text =
        widget.data['courseDateGraduated'] ?? '2023-10-01'; // Example date
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

  Future<void> fetchData() async {
    final institutionResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getInstitution'},
    );
    final coursesResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getCourses'},
    );
    final courseTypeResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getCourseType'},
    );
    final courseCategoryResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getCourseCategory'},
    );

    setState(() {
      institutions = json.decode(institutionResponse.body);
      courses = json.decode(coursesResponse.body);
      courseTypes = json.decode(courseTypeResponse.body);
      courseCategories = json.decode(courseCategoryResponse.body);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.parse(_dateController.text)) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> updateEducationalBackground() async {
    try {
      final url = 'http://localhost/php-delmonte/api/users.php';

      final updatedData = {
        'candidateId': widget.candId,
        'educationalBackground': [
          {
            'institutionId':
                selectedInstitution ?? widget.data['institution_id'],
            'courseId': selectedCourse ?? widget.data['courses_id'],
            'courseTypeId': selectedCourseType ?? widget.data['crs_type_id'],
            'courseDateGraduated': _dateController.text,
          }
        ],
      };

      final formData = {
        'operation': 'updateEducationalBackground',
        'json': json.encode(updatedData),
      };

      final response = await http.post(
        Uri.parse(url),
        body: formData,
      );

      if (response.body == '1') {
        // Success message
        NotificationService.showNotification(
            context, 'Educational background updated successfully!',
            isSuccess: true);
        // Create an instance of ViewProfile and call _fetchProfileData
        await _fetchProfileData();
        Navigator.pop(context);
      } else {
        // Failure message
        NotificationService.showNotification(
            context, 'Failed to update educational background.',
            isSuccess: false);
        Navigator.pop(context);
      }
    } catch (error) {
      // Error handling
      NotificationService.showNotification(
          context, 'Error updating educational background.',
          isSuccess: false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Educational Background'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
              items: institutions.map<String>((dynamic value) {
                return value['institution_name'] ?? 'Unknown';
              }).toList(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select Institution",
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedInstitution = institutions
                      .firstWhere((element) =>
                          element['institution_name'] ==
                          newValue)['institution_id']
                      .toString();
                });
              },
              selectedItem: selectedInstitution != null
                  ? institutions.firstWhere((element) =>
                      element['institution_id'].toString() ==
                      selectedInstitution)['institution_name']
                  : widget.data['institution_name'],
            ),
            const SizedBox(height: 16.0),
            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
              items: courses.map<String>((dynamic value) {
                return value['courses_name'] ?? 'Unknown';
              }).toList(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select Course",
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourse = courses
                      .firstWhere((element) =>
                          element['courses_name'] == newValue)['courses_id']
                      .toString();
                });
              },
              selectedItem: selectedCourse != null
                  ? courses.firstWhere((element) =>
                      element['courses_id'].toString() ==
                      selectedCourse)['courses_name']
                  : widget.data['courses_name'],
            ),
            const SizedBox(height: 16.0),
            DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
              items: courseTypes.map<String>((dynamic value) {
                return value['crs_type_name'] ?? 'Unknown';
              }).toList(),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select Course Type",
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourseType = courseTypes
                      .firstWhere((element) =>
                          element['crs_type_name'] == newValue)['crs_type_id']
                      .toString();
                });
              },
              selectedItem: selectedCourseType != null
                  ? courseTypes.firstWhere((element) =>
                      element['crs_type_id'].toString() ==
                      selectedCourseType)['crs_type_name']
                  : widget.data['crs_type_name'],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Course Date Graduated",
                hintText: "YYYY-MM-DD",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: updateEducationalBackground,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
