import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/user_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewEvents extends StatefulWidget {
  @override
  _ViewEventsState createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  List<dynamic> events = [];
  bool isLoading = true;
  String email = "";
  String rollNumber = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
      rollNumber = prefs.getString("rollNumber") ?? "";
    });
    fetchEvents();
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
      print("Error fetching events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          },
        ),
        title: Text("Registered Events", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
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
