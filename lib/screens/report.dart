import 'package:flutter/material.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController searchController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  String eventType = 'None';
  String position = 'None';
  List<dynamic> events = [];
  List<dynamic> filteredEvents = [];
  bool isLoading = true;
  String userRole = "";

  final Color primaryDark = const Color(0xFF1A1C2E);
  final Color accentColor = const Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role")?.toLowerCase() ?? "";
    setState(() => userRole = role);
    
    if (role != "admin") {
       // Safety check
       debugPrint("Unauthorized access to reports attempt.");
    }
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() => isLoading = true);
    try {
      final fetchedEvents = await EventService().fetchEvents();
      setState(() {
        events = fetchedEvents.reversed.toList();
        filteredEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterEvents() async {
    final filters = {
      'year': yearController.text,
      'symposiumName': searchController.text,
      'college': collegeController.text,
      'interOrIntraEvent': eventType == 'None' ? '' : eventType,
      'position': position == 'None' ? '' : position,
    };

    try {
      final fetchedEvents = await EventService().fetchEvents(filters: filters);
      setState(() => filteredEvents = fetchedEvents);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole.isNotEmpty && userRole != "admin") {
      return const Scaffold(body: Center(child: Text("Access Restricted to Administrators")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Analytical Reports", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchEvents),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileView(),
              desktop: _buildDesktopView(),
            ),
    );
  }

  Widget _buildMobileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(isExpanded: true),
          const SizedBox(height: 20),
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Filters
        Container(
          width: 350,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Record Filters", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const Divider(height: 40),
                _buildFilters(isExpanded: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: filterEvents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Apply Query", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        // Results Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Search Results", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    Text("Showing ${filteredEvents.length} student achievements", style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 30),
                    _buildResultsList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters({required bool isExpanded}) {
    return Column(
      children: [
        _buildInputField(searchController, "Symposium Name", Icons.search),
        const SizedBox(height: 15),
        _buildInputField(collegeController, "Institution", Icons.account_balance),
        const SizedBox(height: 15),
        _buildInputField(yearController, "Batch Year", Icons.calendar_today),
        const SizedBox(height: 15),
        _buildDropdown("Scope", eventType, ['None', 'Inter', 'Intra'], (v) => setState(() => eventType = v!)),
        const SizedBox(height: 15),
        _buildDropdown("Standing", position, ['None', '1', '2', '3'], (v) => setState(() => position = v!)),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryDark),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(backgroundColor: primaryDark, child: const Icon(Icons.person, color: Colors.white, size: 20)),
            title: Text(event['name'] ?? "Participant", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            subtitle: Text("${event['eventName']} | ${event['college']}"),
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataRow("Roll Number", event['rollNumber']),
                    _buildDataRow("Symposium", event['symposiumName']),
                    _buildDataRow("Position", event['positionSecured']),
                    _buildDataRow("Date", event['eventDate']),
                    const SizedBox(height: 15),
                    if (event['certificationLink'] != null && event['certificationLink'] != "")
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        label: const Text("Review Certificate"),
                        style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: primaryDark),
                      )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        Text(value?.toString() ?? "-", style: const TextStyle(color: Color(0xFF1E293B))),
      ]),
    );
  }
}
