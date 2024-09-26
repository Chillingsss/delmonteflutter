import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:delmonteflutter/candidate/notficationService.dart';

class EducationalBackground extends StatefulWidget {
  final dynamic data;
  final int candId;
  final Future<void> Function() refreshProfileData;

  const EducationalBackground({
    Key? key,
    required this.data,
    required this.candId,
    required this.refreshProfileData,
  }) : super(key: key);

  @override
  _EducationalBackgroundState createState() => _EducationalBackgroundState();
}

class _EducationalBackgroundState extends State<EducationalBackground> {
  late List<dynamic> educationalBackgrounds;
  int? selectedIndex;
  bool isAddingNew = false;

  // Update form variables
  List<dynamic> institutions = [];
  List<dynamic> courses = [];
  List<dynamic> courseCategories = [];

  String? selectedInstitution;
  String? selectedCourse;
  String? selectedCourseCategory;

  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      educationalBackgrounds =
          widget.data is List ? widget.data : [widget.data];
    });

    fetchUpdateFormData();
  }

  Future<void> fetchUpdateFormData() async {
    final institutionResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getInstitution'},
    );
    final coursesResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getCourses'},
    );
    final courseCategoryResponse = await http.post(
      Uri.parse('http://localhost/php-delmonte/api/users.php'),
      body: {'operation': 'getCourseCategory'},
    );

    setState(() {
      institutions = json.decode(institutionResponse.body);
      courses = json.decode(coursesResponse.body);
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

  Future<void> updateEducationalBackground(
      Map<String, dynamic> background) async {
    try {
      const url = 'http://localhost/php-delmonte/api/users.php';

      final updatedData = {
        'candidateId': widget.candId,
        'educationalBackground': [
          {
            'educId': background['educ_back_id'],
            'institutionId':
                selectedInstitution ?? background['institution_id'],
            'courseId': selectedCourse ?? background['courses_id'],
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
        NotificationService.showNotification(
            context, 'Educational background updated successfully!',
            isSuccess: true);

        // Call the refreshProfileData method from the parent widget
        await widget.refreshProfileData();

        // Update the local state with the new data
        // setState(() {
        //   final updatedBackground = {
        //     'educ_back_id': background['educ_back_id'],
        //     'institution_id':
        //         selectedInstitution ?? background['institution_id'],
        //     'courses_id': selectedCourse ?? background['courses_id'],
        //     'educ_dategraduate': _dateController.text,
        //     'institution_name': institutions.firstWhere(
        //       (inst) =>
        //           inst['institution_id'].toString() ==
        //           (selectedInstitution ?? background['institution_id']),
        //       orElse: () => {'institution_name': 'Unknown'},
        //     )['institution_name'],
        //     'courses_name': courses.firstWhere(
        //       (course) =>
        //           course['courses_id'].toString() ==
        //           (selectedCourse ?? background['courses_id']),
        //       orElse: () => {'courses_name': 'Unknown'},
        //     )['courses_name'],
        //     'course_categoryName':
        //         background['course_categoryName'] ?? 'Unknown',
        //   };

        //   if (background['educ_back_id'] == null) {
        //     educationalBackgrounds.add(updatedBackground);
        //   } else {
        //     int indexToUpdate = educationalBackgrounds.indexWhere((element) =>
        //         element['educ_back_id'] == background['educ_back_id']);

        //     if (indexToUpdate != -1) {
        //       educationalBackgrounds[indexToUpdate] = updatedBackground;
        //     }
        //   }
        //   // Update the index of the added or updated background
        //   if (background['educ_back_id'] == null) {
        //     selectedIndex = educationalBackgrounds.length - 1;
        //   } else {
        //     selectedIndex = educationalBackgrounds.indexWhere((element) =>
        //         element['educ_back_id'] == background['educ_back_id']);
        //   }

        //   selectedIndex = null;
        //   selectedInstitution = null;
        //   selectedCourse = null;
        //   selectedCourseCategory = null;
        //   isAddingNew = false;
        // });

        setState(() {
          educationalBackgrounds =
              widget.data is List ? widget.data : [widget.data];

          selectedIndex = null;
          selectedInstitution = null;
          selectedCourse = null;
          selectedCourseCategory = null;
          isAddingNew = false;
        });
      } else {
        throw Exception('Server returned: ${response.body}');
      }
    } catch (error) {
      NotificationService.showNotification(
          context, 'Error updating educational background: $error',
          isSuccess: false);
    }
  }

  Widget _buildUpdateForm(Map<String, dynamic> background) {
    // Initialize controllers and selected values
    _dateController.text = background['educ_dategraduate'] ?? '2023-10-01';

    // Use state variables to store selected values
    if (selectedInstitution == null) {
      selectedInstitution = background['institution_id'].toString();
    }
    if (selectedCourse == null) {
      selectedCourse = background['courses_id'].toString();
    }

    return Card(
      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Padding(
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
                print('Selected Institution: $selectedInstitution');
              },
              selectedItem: institutions.firstWhere(
                (element) =>
                    element['institution_id'].toString() == selectedInstitution,
                orElse: () => {'institution_name': 'Unknown'},
              )['institution_name'],
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
                print('Selected Course: $selectedCourse');
              },
              selectedItem: courses.firstWhere(
                (element) => element['courses_id'].toString() == selectedCourse,
                orElse: () => {'courses_name': 'Unknown'},
              )['courses_name'],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateEducationalBackground(background),
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = null;
                      selectedInstitution = null;
                      selectedCourse = null;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Educational Background',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A6338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAddingNew = true;
                    selectedIndex = null;
                    selectedInstitution = null;
                    selectedCourse = null;
                    selectedCourseCategory = null;
                    _dateController.text =
                        DateTime.now().toIso8601String().split('T').first;
                  });
                },
                child: const Text('Add Educational Background'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A6338),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              if (isAddingNew) _buildAddForm(),
              for (int index = 0;
                  index < educationalBackgrounds.length;
                  index++)
                if (selectedIndex != null && index == selectedIndex)
                  _buildUpdateForm(educationalBackgrounds[index])
                else
                  _buildEducationCard(
                      context, educationalBackgrounds[index], index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Padding(
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
              selectedItem: null,
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
              selectedItem: null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (selectedInstitution != null &&
                        selectedCourse != null &&
                        _dateController.text.isNotEmpty) {
                      // Ensure the date is in the correct format
                      final formattedDate = DateFormat('yyyy-MM-dd').format(
                          DateFormat('yyyy-MM-dd').parse(_dateController.text));

                      // Create a new background entry
                      final newBackground = {
                        'educ_back_id': null, // Set to null for new entries
                        'institution_id': selectedInstitution,
                        'courses_id': selectedCourse,
                        'educ_dategraduate': formattedDate,
                        'institution_name': institutions.firstWhere(
                          (inst) =>
                              inst['institution_id'].toString() ==
                              selectedInstitution,
                          orElse: () => {'institution_name': 'Unknown'},
                        )['institution_name'],
                        'courses_name': courses.firstWhere(
                          (course) =>
                              course['courses_id'].toString() == selectedCourse,
                          orElse: () => {'courses_name': 'Unknown'},
                        )['courses_name'],
                        'course_categoryName': 'Unknown',
                      };

                      // Update server first
                      await updateEducationalBackground(newBackground);

                      // Refresh data from server
                      await widget.refreshProfileData();
                      await fetchUpdateFormData();

                      // Reset form
                      setState(() {
                        isAddingNew = false;
                        selectedInstitution = null;
                        selectedCourse = null;
                        _dateController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all fields'),
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAddingNew = false;
                      selectedInstitution = null;
                      selectedCourse = null;
                      _dateController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(
      BuildContext context, Map<String, dynamic> background, int index) {
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
                    setState(() {
                      selectedIndex = index;
                    });
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
