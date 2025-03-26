import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'user_screen.dart';

class Report extends StatefulWidget {
  const Report();

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

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
    });
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final String apiUrl = "http://localhost:5000/view-events"; // Replace if needed

    try {
        final response = await http.get(
        Uri.parse(
          email.endsWith('@kongu.ac.in') ? apiUrl : "$apiUrl?email=$email",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
         events = json.decode(response.body).reversed.toList();
          filteredEvents = events;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching events: $e");
    }
  }

  void filterEvents() async {
    final queryParameters = {
         if (!email.endsWith('@kongu.ac.in'))
      'email': email,
      'year': yearController.text,
      'symposiumName': searchController.text,
      'college': collegeController.text,
      'interOrIntraEvent': eventType == 'None' ? '' : eventType,
      'position': position == 'None' ? '' : position,
    };

    final uri = Uri.http('localhost:5000', '/view-events', queryParameters);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          filteredEvents = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load filtered events");
      }
    } catch (e) {
      print("Error fetching filtered events: $e");
    }
  }

  Future<void> downloadReport() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Downloading report...")));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Filtered Events Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  "Full Name",
                  "Email",
                  "College Name",
                  "Contact",
                  "Roll Number",
                  "Symposium Name",
                  "Event Type",
                  "Team or Individual",
                  "Team Members",
                  "Event Date",
                  "Event Days Spent",
                  "Prize Amount",
                  "Position Secured",
                  "Certification Link",
                  "Inter or Intra Event",
                  "Date Registered",
                ],
                data:
                    filteredEvents.map((event) {
                      return [
                        event["name"]?.toString() ?? "",
                        event["email"]?.toString() ?? "",
                        event["college"]?.toString() ?? "",
                        event["contact"]?.toString() ?? "",
                        event["rollNumber"]?.toString() ?? "",
                        event["symposiumName"]?.toString() ?? "",
                        event["eventType"]?.toString() ?? "",
                        event["teamOrIndividual"]?.toString() ?? "",
                        event["teamMembers"]?.toString() ?? "",
                        event["eventDate"]?.toString() ?? "",
                        event["eventDaysSpent"]?.toString() ?? "",
                        event["prizeAmount"]?.toString() ?? "",
                        event["positionSecured"]?.toString() ?? "",
                        event["certificationLink"]?.toString() ?? "",
                        event["interOrIntraEvent"]?.toString() ?? "",
                        event["date"]?.toString() ?? "",
                      ];
                    }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/report.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Report downloaded to $path")));
  }

  void _clearFilter(TextEditingController controller) {
    setState(() {
      controller.clear();
    });
  }

  void _resetFilters() {
    setState(() {
      searchController.clear();
      collegeController.clear();
      yearController.clear();
      position = 'None';  
      eventType = 'None';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          },
        ),
        title: Text(
          "Report",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetFilters),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GridView.count(
                            crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio:
                                constraints.maxWidth > 600 ? 2 : 1.5,
                            children: [
                              _buildSummaryCard(
                                "Total Events Participated",
                                events.length.toString(),
                                Icons.event,
                              ),
                              _buildSummaryCard(
                                "Total Intra Events",
                                events
                                    .where(
                                      (event) =>
                                          event['interOrIntraEvent'] == 'Intra',
                                    )
                                    .length
                                    .toString(),
                                Icons.school,
                              ),
                              _buildSummaryCard(
                                "Total Inter Events",
                                events
                                    .where(
                                      (event) =>
                                          event['interOrIntraEvent'] == 'Inter',
                                    )
                                    .length
                                    .toString(),
                                Icons.public,
                              ),
                              _buildSummaryCard(
                                "Top 3 Positions",
                                events
                                    .where(
                                      (event) =>
                                          int.tryParse(
                                                event['positionSecured'],
                                              ) !=
                                              null &&
                                          int.parse(event['positionSecured']) <=
                                              3,
                                    )
                                    .length
                                    .toString(),
                                Icons.emoji_events,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              _buildFilterField(
                                searchController,
                                "Search by Symposium Name",
                                Icons.search,
                              ),
                              _buildFilterField(
                                collegeController,
                                "Search by College Name",
                                Icons.school,
                              ),
                              _buildFilterField(
                                yearController,
                                "Year",
                                Icons.calendar_today,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: eventType,
                                  decoration: InputDecoration(
                                    labelText: "Event Type",
                                    prefixIcon: Icon(Icons.category),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items:
                                      <String>['None', 'Inter', 'Intra'].map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      eventType = newValue!;
                                    });
                                  },
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: position,
                                  decoration: InputDecoration(
                                    labelText: "Position",
                                    prefixIcon: Icon(Icons.emoji_events),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items:
                                      <String>['None', '1', '2', '3'].map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      position = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: filterEvents,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text("Apply Filter"),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: downloadReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text("Download Report"),
                        ),
                        ListView.builder(
                          padding: EdgeInsets.all(10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
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
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Full Name: ${event['name']}"),
                                        Text("Email: ${event['email']}"),
                                        Text(
                                          "College Name: ${event['college']}",
                                        ),
                                        Text("Contact: ${event['contact']}"),
                                        Text(
                                          "Roll Number: ${event['rollNumber']}",
                                        ),
                                        Text(
                                          "Symposium Name: ${event['symposiumName']}",
                                        ),
                                        Text(
                                          "Event Type: ${event['eventType']}",
                                        ),
                                        Text(
                                          "Team or Individual: ${event['teamOrIndividual']}",
                                        ),
                                        Text(
                                          "Team Members: ${event['teamMembers']}",
                                        ),
                                        Text(
                                          "Event Date: ${event['eventDate']}",
                                        ),
                                        Text(
                                          "Event Days Spent: ${event['eventDaysSpent']}",
                                        ),
                                        Text(
                                          "Prize Amount: ${event['prizeAmount']}",
                                        ),
                                        Text(
                                          "Position Secured: ${event['positionSecured']}",
                                        ),
                                        Text(
                                          "Certification Link: ${event['certificationLink']}",
                                        ),
                                        Text(
                                          "Inter or Intra Event: ${event['interOrIntraEvent']}",
                                        ),
                                        Text(
                                          "Date Registered: ${event['date']}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20.0,
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Modern color
                  letterSpacing: 1.2, // Spacing for better readability
                  fontFamily: 'Montserrat', // Stylish font
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _clearFilter(controller),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
