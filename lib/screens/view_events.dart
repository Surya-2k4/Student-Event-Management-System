import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';
import 'package:flutter_auth/services/event_services.dart';

class ViewEvents extends StatefulWidget {
  const ViewEvents({super.key});

  @override
  State<ViewEvents> createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  List<dynamic> events = [];
  bool isLoading = true;
  String email = "";
  String userRole = "student";

  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final storedEmail = prefs.getString("email") ?? "";
    final storedRole = prefs.getString("role")?.toLowerCase() ?? "student";

    if (token.isEmpty) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }

    setState(() {
      email = storedEmail;
      userRole = storedRole;
    });

    // On refresh, redirect to dashboard if root
    if (mounted) {
      Future.microtask(() {
        if (mounted && !Navigator.canPop(context)) {
          String targetRoute = (storedRole == "admin" || storedRole == "staff") ? "/admin" : "/user_screen";
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      });
    }

    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final fetchedEvents = await EventService().fetchEvents(
        email: email.endsWith('@kongu.ac.in') ? null : email,
      );

      if (mounted) {
        setState(() {
          events = fetchedEvents.reversed.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("Error fetching events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text("Achievement Archive", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _fetchEvents),
          const SizedBox(width: 10),
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
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No achievement records found", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text("Try refreshing or add a new event", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildList({required int crossAxisCount}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Summary of Records (${events.length})", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF1E293B))),
              const SizedBox(height: 25),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) => _buildEventCard(events[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final String title = event['eventName'] ?? event['symposiumName'] ?? "Achievement";
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryDark.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.workspace_premium_outlined, color: primaryDark, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B))),
        subtitle: Text("${event['college']} | ${event['eventDate']}", style: TextStyle(color: Colors.grey[500])),
        iconColor: primaryDark,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Participant", event['name']),
                _buildDetailRow("Roll Number", event['rollNumber']),
                _buildDetailRow("Category", event['eventType']),
                _buildDetailRow("Standing", event['positionSecured']),
                _buildDetailRow("Scope", event['interOrIntraEvent']),
                const SizedBox(height: 20),
                if (event['certificationLink'] != null && event['certificationLink'].toString().isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text("Certificate Proof"),
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
