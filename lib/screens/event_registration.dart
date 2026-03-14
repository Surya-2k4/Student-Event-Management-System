import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/services/auth_services.dart';
import 'package:flutter_auth/services/event_services.dart';

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
  String userRole = "student";

  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final email = prefs.getString("email") ?? "";
    final role = prefs.getString("role")?.toLowerCase() ?? "student";

    if (token.isEmpty) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }

    setState(() => userRole = role);

    // On browser refresh, redirect to dashboard if root
    if (mounted) {
      Future.microtask(() {
        if (mounted && !Navigator.canPop(context)) {
          String targetRoute = (role == "admin" || role == "staff") ? "/admin" : "/user_screen";
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      });
    }

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

    final success = await EventService().registerEvent({
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
    });

    setState(() {
      isLoading = false;
    });

    if (success) {
      _showDialog("Event registered successfully!", Colors.green);
      _clearFields();
    } else {
      _showMessage("Registration failed. Please try again.", Colors.red);
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
    int gridCols = MediaQuery.of(context).size.width > 800 ? 2 : 1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              String targetRoute = "/user_screen";
              final prefs = await SharedPreferences.getInstance();
              final role = prefs.getString("role")?.toLowerCase() ?? "";
              if (role == "admin" || role == "staff") {
                targetRoute = "/admin";
              }
              if (mounted) Navigator.pushReplacementNamed(context, targetRoute);
            }
          },
        ),
        title: const Text("New Achievement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading("Technical Details", "Provide the core information about the event"),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridCols,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 25,
                  childAspectRatio: gridCols == 1 ? 4 : 5.5,
                  children: [
                    _buildInput(nameController, "Participant Name", Icons.person_outline, readOnly: true),
                    _buildInput(emailController, "Institutional Email", Icons.email_outlined, readOnly: true),
                    _buildInput(rollNumberController, "Roll Number", Icons.badge_outlined, readOnly: true),
                    _buildInput(contactController, "Contact Number", Icons.phone_outlined),
                    _buildInput(collegeController, "Institution Name", Icons.account_balance_outlined),
                    _buildInput(symposiumNameController, "Symposium Title", Icons.event_note_outlined),
                    _buildInput(eventNameController, "Specific Event", Icons.emoji_events_outlined),
                    _buildInput(eventTypeController, "Event Category", Icons.category_outlined),
                    _buildInput(teamOrIndividualController, "Entry Type", Icons.groups_outlined),
                    _buildInput(teamMembersController, "Team Members (if any)", Icons.people_outline),
                    _buildDateInput(),
                    _buildInput(eventDaysSpentController, "Duration (Days)", Icons.timer_outlined, isNumber: true),
                    _buildInput(prizeAmountController, "Award Amount", Icons.currency_rupee, isNumber: true),
                    _buildInput(positionSecuredController, "Rank/Position", Icons.stars_outlined),
                    _buildInput(certificationLinkController, "Certificate URL", Icons.link_rounded),
                    _buildDropdown("Participation Scope", interOrIntraEvent, ['Inter', 'Intra'], (v) => setState(() => interOrIntraEvent = v)),
                  ],
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: registerEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Register Achievement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        const SizedBox(height: 5),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: eventDateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: "Event Date",
        prefixIcon: const Icon(Icons.date_range_outlined, color: Color(0xFF3B82F6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF3B82F6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
      validator: (v) => v == null ? "Required" : null,
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
