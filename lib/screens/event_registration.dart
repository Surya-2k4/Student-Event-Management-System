import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/services/auth_services.dart';

class EventRegistration extends StatefulWidget {
  const EventRegistration({super.key});

  @override
  _EventRegistrationState createState() => _EventRegistrationState();
}

class _EventRegistrationState extends State<EventRegistration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController symposiumNameController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController teamOrIndividualController =
      TextEditingController();
  final TextEditingController teamMembersController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDaysSpentController =
      TextEditingController();
  final TextEditingController prizeAmountController = TextEditingController();
  final TextEditingController positionSecuredController =
      TextEditingController();
  final TextEditingController certificationLinkController =
      TextEditingController();
  String? interOrIntraEvent;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email") ?? "";
    final userDetails = await AuthService().fetchUserDetails(email);
    if (userDetails != null) {
      setState(() {
        nameController.text = userDetails["name"]!;
        rollNumberController.text = userDetails["rollNumber"]!;
        emailController.text = userDetails["email"]!;
      });
    }
  }

  Future<void> registerEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String apiUrl = "http://localhost:5000/register-event";

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "email": emailController.text,
        "eventName": eventNameController.text,
        "college": collegeController.text,
        "contact": contactController.text,
        "rollNumber": rollNumberController.text,
        "symposiumName": symposiumNameController.text,
        "eventType": eventTypeController.text,
        "teamOrIndividual": teamOrIndividualController.text,
        "teamMembers": teamMembersController.text,
        "eventDate": eventDateController.text,
        "eventDaysSpent": eventDaysSpentController.text,
        "prizeAmount": prizeAmountController.text,
        "positionSecured": positionSecuredController.text,
        "certificationLink": certificationLinkController.text,
        "interOrIntraEvent": interOrIntraEvent,
      }),
    );

    setState(() {
      isLoading = false;
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _showDialog("Event registered successfully!", Colors.green);
      _clearFields();
    } else {
      _showMessage(data['message'], Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registration Status"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacementNamed(
                  context,
                  "/user_screen",
                ); // Navigate back to user screen
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    eventNameController.clear();
    collegeController.clear();
    contactController.clear();
    rollNumberController.clear();
    symposiumNameController.clear();
    eventTypeController.clear();
    teamOrIndividualController.clear();
    teamMembersController.clear();
    eventDateController.clear();
    eventDaysSpentController.clear();
    prizeAmountController.clear();
    positionSecuredController.clear();
    certificationLinkController.clear();
    interOrIntraEvent = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        eventDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/user_screen");
          },
        ),
        title: const Text(
          "Event Registration",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(nameController, "Full Name", Icons.person),
                _buildInputField(emailController, "Email", Icons.email),
                _buildInputField(
                  collegeController,
                  "College Name",
                  Icons.school,
                ),
                _buildInputField(
                  contactController,
                  "Contact Number",
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Contact number is required';
                    } else if (value.length != 10) {
                      return 'Contact number should be 10 digits';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  rollNumberController,
                  "Roll Number",
                  Icons.confirmation_number,
                ),
                _buildInputField(
                  symposiumNameController,
                  "Symposium Name",
                  Icons.event_note,
                ),
                _buildInputField(
                  eventNameController,
                  "Event Name",
                  Icons.event,
                ),
                _buildInputField(
                  eventTypeController,
                  "Event Type",
                  Icons.category,
                ),
                _buildInputField(
                  teamOrIndividualController,
                  "Team or Individual",
                  Icons.group,
                ),
                _buildInputField(
                  teamMembersController,
                  "Team Members Name",
                  Icons.people,
                ),
                _buildDateInputField(
                  eventDateController,
                  "Event Date",
                  Icons.date_range,
                  context,
                ),
                _buildInputField(
                  eventDaysSpentController,
                  "Event Days Spent",
                  Icons.timer,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event days spent is required';
                    } else if (int.tryParse(value) == null) {
                      return 'Event days spent should be a number';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  prizeAmountController,
                  "Prize Amount",
                  Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prize amount is required';
                    } else if (int.tryParse(value) == null) {
                      return 'Prize amount should be a number';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  positionSecuredController,
                  "Position Secured",
                  Icons.emoji_events,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Position secured is required';
                    } else if (int.tryParse(value) == null) {
                      return 'Position secured should be a number';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  certificationLinkController,
                  "Certification Link",
                  Icons.link,
                ),
                _buildDropdownField(
                  "Inter & Intra Event",
                  Icons.event,
                  (value) {
                    setState(() {
                      interOrIntraEvent = value;
                    });
                  },
                  interOrIntraEvent,
                  ["Inter", "Intra"],
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                      ),
                    )
                    : ElevatedButton(
                      onPressed: registerEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black),
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildDateInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black),
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    ValueChanged<String?> onChanged,
    String? value,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black),
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
