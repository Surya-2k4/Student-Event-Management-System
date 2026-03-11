import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';

class EventRegistration extends StatefulWidget {
  const EventRegistration({super.key});

  @override
  State<EventRegistration> createState() => _EventRegistrationState();
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

    setState(() {
      isLoading = true;
    });

    final eventData = {
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
      "eventDaysSpent": int.tryParse(eventDaysSpentController.text) ?? 0,
      "prizeAmount": double.tryParse(prizeAmountController.text) ?? 0.0,
      "positionSecured": positionSecuredController.text,
      "certificationLink": certificationLinkController.text,
      "interOrIntraEvent": interOrIntraEvent,
    };

    final success = await EventService().registerEvent(eventData);

    setState(() {
      isLoading = false;
    });

    if (success) {
      _showDialog("Event registered successfully!", Colors.green);
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to register event."), backgroundColor: Colors.red),
      );
    }
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/user_screen");
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    eventNameController.clear();
    collegeController.clear();
    contactController.clear();
    symposiumNameController.clear();
    eventTypeController.clear();
    teamOrIndividualController.clear();
    teamMembersController.clear();
    eventDateController.clear();
    eventDaysSpentController.clear();
    prizeAmountController.clear();
    positionSecuredController.clear();
    certificationLinkController.clear();
    setState(() => interOrIntraEvent = null);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Register Achievement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: ResponsiveLayout(
        mobile: _buildForm(padding: 16, crossAxisCount: 1),
        desktop: _buildForm(padding: 40, crossAxisCount: 2),
      ),
    );
  }

  Widget _buildForm({required double padding, required int crossAxisCount}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 20,
                  childAspectRatio: crossAxisCount == 1 ? 3.5 : 5,
                  children: [
                    _buildInputField(nameController, "Full Name", Icons.person, readOnly: true),
                    _buildInputField(emailController, "Email", Icons.email, readOnly: true),
                    _buildInputField(rollNumberController, "Roll Number", Icons.confirmation_number, readOnly: true),
                    _buildInputField(contactController, "Contact Number", Icons.phone, keyboardType: TextInputType.phone),
                    _buildInputField(collegeController, "College/Institution", Icons.school),
                    _buildInputField(symposiumNameController, "Symposium Name", Icons.event_note),
                    _buildInputField(eventNameController, "Event Name", Icons.event),
                    _buildInputField(eventTypeController, "Event Category", Icons.category),
                    _buildInputField(teamOrIndividualController, "Team Size/Type", Icons.group),
                    _buildInputField(teamMembersController, "Team Members", Icons.people),
                    _buildDateInputField(eventDateController, "Event Date", Icons.date_range, context),
                    _buildInputField(eventDaysSpentController, "Days Involved", Icons.timer, keyboardType: TextInputType.number),
                    _buildInputField(prizeAmountController, "Prize/Cash Award", Icons.attach_money, keyboardType: TextInputType.number),
                    _buildInputField(positionSecuredController, "Position (1st/2nd...)", Icons.emoji_events),
                    _buildInputField(certificationLinkController, "Certificate URL", Icons.link),
                    _buildDropdownField("Event Scope", Icons.public, (v) => setState(() => interOrIntraEvent = v), interOrIntraEvent, ["Inter", "Intra"]),
                  ],
                ),
                const SizedBox(height: 40),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: registerEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          minimumSize: const Size(300, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text("Submit Registration", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.assignment_turned_in, size: 50, color: Colors.indigo.withOpacity(0.8)),
        const SizedBox(height: 10),
        const Text("Event Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Please fill in all the details of your achievement", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }
}
