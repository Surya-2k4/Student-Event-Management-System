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
  final TextEditingController teamOrIndividualController = TextEditingController();
  final TextEditingController teamMembersController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDaysSpentController = TextEditingController();
  final TextEditingController prizeAmountController = TextEditingController();
  final TextEditingController positionSecuredController = TextEditingController();
  final TextEditingController certificationLinkController = TextEditingController();
  String? interOrIntraEvent;

  bool isLoading = false;

  final Color primaryDark = const Color(0xFF1A1C2E);
  final Color accentColor = const Color(0xFF2DD4BF);

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
      if (mounted) {
        setState(() {
          nameController.text = userDetails["name"]!;
          rollNumberController.text = userDetails["rollNumber"]!;
          emailController.text = userDetails["email"]!;
        });
      }
    }
  }

  Future<void> registerEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

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

    setState(() => isLoading = false);

    if (success) {
      _showSuccessDialog();
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission failed. Check your connection."), backgroundColor: Colors.redAccent));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Achievement Logged", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Your event details have been successfully recorded in the central repository."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, "/user_screen");
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            child: const Text("Return to Portal", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("New Achievement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildFormView(padding: 20, gridCols: 1),
        desktop: _buildFormView(padding: 40, gridCols: 2),
      ),
    );
  }

  Widget _buildFormView({required double padding, required int gridCols}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Form(
            key: _formKey,
            child: Column(
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
                    _buildInput(rollNumberController, "Roll ID", Icons.badge_outlined, readOnly: true),
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
                    _buildInput(certificationLinkController, "Credential URL", Icons.link_rounded),
                    _buildDropdown("Participation Scope", interOrIntraEvent, ['Inter', 'Intra'], (v) => setState(() => interOrIntraEvent = v)),
                  ],
                ),
                const SizedBox(height: 50),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: registerEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          minimumSize: const Size(400, 65),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: primaryDark.withOpacity(0.3),
                        ),
                        child: const Text("Log Achievement", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title, String sub) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        const SizedBox(height: 5),
        Text(sub, style: TextStyle(color: Colors.grey[500])),
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
        prefixIcon: Icon(icon, color: primaryDark, size: 20),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: eventDateController,
      readOnly: true,
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (d != null) setState(() => eventDateController.text = d.toIso8601String().split('T')[0]);
      },
      decoration: InputDecoration(
        labelText: "Event Date",
        prefixIcon: Icon(Icons.calendar_month_outlined, color: primaryDark, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.public_rounded, color: primaryDark, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      validator: (v) => v == null ? "Required" : null,
    );
  }
}
