import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/user_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewEvents extends StatefulWidget {
  const ViewEvents({super.key});

  @override
  State<ViewEvents> createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  List<dynamic> events = [];
  bool isLoading = true;
  String email = "";
<<<<<<< Updated upstream
  String rollNumber = "";
=======

  final Color primaryDark = const Color(0xFF0F172A); // Deep Navy
  final Color accentColor = const Color(0xFF3B82F6); // Vibrant Blue
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
      email = prefs.getString("email") ?? "";
      rollNumber = prefs.getString("rollNumber") ?? "";
    });
    fetchEvents();
=======
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
>>>>>>> Stashed changes
  }

  Future<void> fetchEvents() async {
    final String apiUrl =
        "http://localhost:5000/view-events"; // Replace if needed

    try {
      final response = await http.get(
        Uri.parse(
          email.endsWith('@kongu.ac.in') ? apiUrl : "$apiUrl?email=$email",
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            events = json.decode(response.body).reversed.toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load events");
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
<<<<<<< Updated upstream
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          },
=======
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
>>>>>>> Stashed changes
        ),
        title: Text("Registered Events", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
<<<<<<< Updated upstream
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : events.isEmpty
              ? Center(
                child: Text(
                  "No events registered yet!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Total Event Registrations: ${events.length}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
=======
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
>>>>>>> Stashed changes
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                event["eventName"][0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              event["eventName"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(event["college"]),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow("Full Name", event['name']),
                                    _buildDetailRow("Email", event['email']),
                                    _buildDetailRow(
                                      "College Name",
                                      event['college'],
                                    ),
                                    _buildDetailRow(
                                      "Contact",
                                      event['contact'],
                                    ),
                                    _buildDetailRow(
                                      "Roll Number",
                                      event['rollNumber'],
                                    ),
                                    _buildDetailRow(
                                      "Symposium Name",
                                      event['symposiumName'],
                                    ),
                                    _buildDetailRow(
                                      "Event Type",
                                      event['eventType'],
                                    ),
                                    _buildDetailRow(
                                      "Team or Individual",
                                      event['teamOrIndividual'],
                                    ),
                                    _buildDetailRow(
                                      "Team Members",
                                      event['teamMembers'],
                                    ),
                                    _buildDetailRow(
                                      "Event Date",
                                      event['eventDate'],
                                    ),
                                    _buildDetailRow(
                                      "Event Days Spent",
                                      event['eventDaysSpent'].toString(),
                                    ),
                                    _buildDetailRow(
                                      "Prize Amount",
                                      event['prizeAmount'].toString(),
                                    ),
                                    _buildDetailRow(
                                      "Position Secured",
                                      event['positionSecured'],
                                    ),
                                    _buildDetailRow(
                                      "Certification Link",
                                      event['certificationLink'],
                                    ),
                                    _buildDetailRow(
                                      "Inter or Intra Event",
                                      event['interOrIntraEvent'],
                                    ),
                                    _buildDetailRow(
                                      "Date Registered",
                                      event['date'],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
