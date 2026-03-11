import 'package:flutter/material.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  String email = "";
  String userRole = "Student";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
      userRole = prefs.getString("role") ?? "Student";
    });
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() => isLoading = true);
    try {
      final fetchedEvents = await EventService().fetchEvents(
        email: (userRole == "Admin" || userRole == "Staff") ? null : email,
      );
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
      final fetchedEvents = await EventService().fetchEvents(
        email: (userRole == "Admin" || userRole == "Staff") ? null : email,
        filters: filters,
      );
      setState(() {
        filteredEvents = fetchedEvents;
      });
    } catch (e) {
      debugPrint("Error filtering: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Participation Reports", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchEvents),
          IconButton(icon: const Icon(Icons.download, color: Colors.white), onPressed: _downloadPdf),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildCompactView(),
              desktop: _buildWideView(),
            ),
    );
  }

  Widget _buildCompactView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewDashboard(events),
          const SizedBox(height: 20),
          _buildFilters(crossAxisCount: 1),
          const SizedBox(height: 20),
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildWideView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Filter
        Container(
          width: 300,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                _buildFilters(crossAxisCount: 1),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: filterEvents,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                _buildOverviewDashboard(events),
                const SizedBox(height: 30),
                _buildResultsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters({required int crossAxisCount}) {
    return Column(
      children: [
        _buildFilterField(searchController, "Symposium Name", Icons.search),
        _buildFilterField(collegeController, "College Name", Icons.school),
        _buildFilterField(yearController, "Year", Icons.calendar_today),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: eventType,
          decoration: InputDecoration(labelText: "Event Scope", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: ['None', 'Inter', 'Intra'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => eventType = v!),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: position,
          decoration: InputDecoration(labelText: "Position Secured", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: ['None', '1', '2', '3'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => position = v!),
        ),
        if (crossAxisCount == 1) ...[
          const SizedBox(height: 20),
          ElevatedButton(onPressed: filterEvents, child: const Text("Search")),
        ]
      ],
    );
  }

  Widget _buildOverviewDashboard(List<dynamic> events) {
    final int total = events.length;
    final int wins = events.where((e) => ['1','2','3'].contains(e['positionSecured']?.toString())).length;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.indigo, Colors.indigoAccent]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("Total Participation", "$total", Icons.event),
          _buildStat("Medals/Wins", "$wins", Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.star, color: Colors.white)),
            title: Text(event['eventName'] ?? event['symposiumName'] ?? "Unnamed", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${event['name']} | ${event['eventDate']}"),
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Roll No", event['rollNumber']),
                    _buildDetailRow("College", event['college']),
                    _buildDetailRow("Symposium", event['symposiumName']),
                    _buildDetailRow("Position", event['positionSecured']),
                    _buildDetailRow("Scope", event['interOrIntraEvent']),
                    if (event['certificationLink'] != null)
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.link), label: const Text("View Certificate")),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)), Text(value?.toString() ?? "-")]),
    );
  }

  Widget _buildFilterField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.indigo), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Future<void> _downloadPdf() async {
     // Placeholder for legacy PDF logic
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF generation started...")));
  }
}
