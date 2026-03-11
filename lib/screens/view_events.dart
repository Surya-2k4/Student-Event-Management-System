import 'package:flutter/material.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewEvents extends StatefulWidget {
  const ViewEvents({super.key});

  @override
  State<ViewEvents> createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  List<dynamic> events = [];
  bool isLoading = true;
  String userRole = "Student";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
      userRole = prefs.getString("role") ?? "Student";
    });
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => isLoading = true);
    try {
      final fetched = await EventService().fetchEvents(
        email: (userRole == "Admin" || userRole == "Staff") ? null : email,
      );
      setState(() {
        events = fetched.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Achievement Records", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
           IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchEvents),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? _buildEmptyState()
              : ResponsiveLayout(
                  mobile: _buildList(crossAxisCount: 1),
                  desktop: _buildList(crossAxisCount: 3),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No registrations found", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList({required int crossAxisCount}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("Showing ${events.length} records", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          if (crossAxisCount == 1)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) => _buildEventCard(events[index]),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.5,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) => _buildEventCard(events[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final String title = event['eventName'] ?? event['symposiumName'] ?? "Event";
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: Colors.indigo, child: Text(title[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${event['college']} | ${event['eventDate']}"),
        children: [
           Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 _buildDetail("Participant", event['name']),
                 _buildDetail("Roll No", event['rollNumber']),
                 _buildDetail("Event Type", event['eventType']),
                 _buildDetail("Position", event['positionSecured']),
                 _buildDetail("Inter/Intra", event['interOrIntraEvent']),
                 if (event['certificationLink'] != null && event['certificationLink'].toString().isNotEmpty)
                    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.link), label: const Text("View Certificate")),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)), Text(value?.toString() ?? "-")]),
    );
  }
}
