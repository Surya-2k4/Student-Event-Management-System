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
  final TextEditingController teamOrIndividualController = TextEditingController();
  final TextEditingController teamMembersController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDaysSpentController = TextEditingController();
  final TextEditingController prizeAmountController = TextEditingController();
  final TextEditingController positionSecuredController = TextEditingController();
  final TextEditingController certificationLinkController = TextEditingController();
  String? interOrIntraEvent;

  bool isLoading = false;
  String userRole = "student";

  // Modern Tech Palette
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color primaryDark = const Color(0xFF0F172A);
  final Color secondaryDark = const Color(0xFF1E293B);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color textPrimary = const Color(0xFF1E293B);
  final Color textSecondary = const Color(0xFF64748B);
  final Color inputBgInfo = Colors.grey.shade50;

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

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    if (success) {
      _showDialog("Achievement successfully logged to the repository.", const Color(0xFF10B981));
      _clearFields();
    } else {
      _showMessage("Data ingestion failed. Please retry.", Colors.redAccent);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext c) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: const Offset(0, 10))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_rounded, color: color, size: 48),
                ),
                const SizedBox(height: 24),
                const Text("Operation Successful", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5, fontSize: 16)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.pushReplacementNamed(context, "/user_screen");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    child: const Text("Acknowledge", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
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
    interOrIntraEvent = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentBlue,
              onPrimary: Colors.white,
              onSurface: textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: accentBlue)),
          ),
          child: child!,
        );
      },
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
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
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
        ),
        title: const Text("New Log Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryDark, secondaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeading("Technical Payload", "Input meticulous details of the extracurricular milestone", Icons.assignment_rounded),
                    const SizedBox(height: 40),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: gridCols,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: gridCols == 1 ? 4.5 : 5,
                      children: [
                        _buildInput(nameController, "Operative ID", Icons.person_rounded, readOnly: true),
                        _buildInput(emailController, "Authorized Email", Icons.alternate_email_rounded, readOnly: true),
                        _buildInput(rollNumberController, "System Roll No", Icons.badge_rounded, readOnly: true),
                        _buildInput(contactController, "Primary Contact", Icons.call_rounded),
                        _buildInput(collegeController, "Base Institution", Icons.account_balance_rounded),
                        _buildInput(symposiumNameController, "Framework / Symposium", Icons.event_note_rounded),
                        _buildInput(eventNameController, "Specific Action Event", Icons.emoji_events_rounded),
                        _buildInput(eventTypeController, "Type Classification", Icons.category_rounded),
                        _buildInput(teamOrIndividualController, "Operational Mode", Icons.groups_rounded),
                        _buildInput(teamMembersController, "Contingent Details", Icons.group_add_rounded),
                        _buildDateInput(),
                        _buildInput(eventDaysSpentController, "T-Minus (Days Spent)", Icons.timer_rounded, isNumber: true),
                        _buildInput(prizeAmountController, "Acquired Grant / Prize", Icons.monetization_on_rounded, isNumber: true),
                        _buildInput(positionSecuredController, "Final Standing", Icons.stars_rounded),
                        _buildInput(certificationLinkController, "Cryptography / Proof URL", Icons.link_rounded),
                        _buildDropdown("Execution Scope", interOrIntraEvent, ['Inter', 'Intra'], (v) => setState(() => interOrIntraEvent = v)),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const Divider(height: 1),
                    const SizedBox(height: 35),
                    isLoading
                        ? Center(child: CircularProgressIndicator(color: accentBlue, strokeWidth: 3))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _clearFields,
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
                                child: const Text("Flush Data", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: registerEvent,
                                icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                                label: const Text("Commit to Record", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: accentBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(fontSize: 15, color: textSecondary, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontWeight: FontWeight.w600, color: readOnly ? textSecondary : textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: readOnly ? Colors.grey.shade400 : accentBlue, size: 20),
        filled: true,
        fillColor: readOnly ? inputBgInfo : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentBlue, width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
      validator: (v) => v!.isEmpty ? "Mandatory field" : null,
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      controller: eventDateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: "Execution Date",
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(Icons.calendar_month_rounded, color: accentBlue, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentBlue, width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
      validator: (v) => v!.isEmpty ? "Mandatory field" : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(Icons.public_rounded, color: accentBlue, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentBlue, width: 1.5)),
        contentPadding: const EdgeInsets.all(20),
      ),
      validator: (v) => v == null ? "Mandatory field" : null,
    );
  }
}
