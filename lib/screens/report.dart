import 'package:flutter/material.dart';
import 'package:flutter_auth/services/event_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'user_screen.dart';

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
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedEvents = await EventService().fetchEvents(
        email: email.endsWith('@kongu.ac.in') ? null : email,
      );

      setState(() {
        events = fetchedEvents.reversed.toList();
        filteredEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching events: $e");
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
        email: email.endsWith('@kongu.ac.in') ? null : email,
        filters: filters,
      );

      setState(() {
        filteredEvents = fetchedEvents;
      });
    } catch (e) {
      debugPrint("Error fetching filtered events: $e");
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
              pw.TableHelper.fromTextArray(
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

    if (!mounted) return;
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
                        _buildOverviewDashboard(events),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              final String displayName =
                                  (event["eventName"] ??
                                          event["symposiumName"] ??
                                          "Unnamed Event")
                                      .toString();
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
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
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildDetailText(
                                            "Full Name",
                                            event['name'],
                                          ),
                                          _buildDetailText(
                                            "Email",
                                            event['email'],
                                          ),
                                          _buildDetailText(
                                            "College Name",
                                            event['college'],
                                          ),
                                          _buildDetailText(
                                            "Contact",
                                            event['contact'],
                                          ),
                                          _buildDetailText(
                                            "Roll Number",
                                            event['rollNumber'],
                                          ),
                                          _buildDetailText(
                                            "Symposium Name",
                                            event['symposiumName'],
                                          ),
                                          _buildDetailText(
                                            "Event Type",
                                            event['eventType'],
                                          ),
                                          _buildDetailText(
                                            "Team or Individual",
                                            event['teamOrIndividual'],
                                          ),
                                          _buildDetailText(
                                            "Team Members",
                                            event['teamMembers'],
                                          ),
                                          _buildDetailText(
                                            "Event Date",
                                            event['eventDate'],
                                          ),
                                          _buildDetailText(
                                            "Event Days Spent",
                                            event['eventDaysSpent'],
                                          ),
                                          _buildDetailText(
                                            "Prize Amount",
                                            event['prizeAmount'],
                                          ),
                                          _buildDetailText(
                                            "Position Secured",
                                            event['positionSecured'],
                                          ),
                                          _buildDetailText(
                                            "Certification Link",
                                            event['certificationLink'],
                                          ),
                                          _buildDetailText(
                                            "Inter or Intra Event",
                                            event['interOrIntraEvent'],
                                          ),
                                          _buildDetailText(
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
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildOverviewDashboard(List<dynamic> events) {
    final int total = events.length;
    final int intra =
        events.where((e) => e['interOrIntraEvent'] == 'Intra').length;
    final int inter =
        events.where((e) => e['interOrIntraEvent'] == 'Inter').length;
    final int top3 =
        events.where((e) {
          final pos = int.tryParse(e['positionSecured']?.toString() ?? '');
          return pos != null && pos <= 3;
        }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Event Participation Overview",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$total",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Events",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildMetricItem("Intra", "$intra", Icons.school),
              _buildMetricItem("Inter", "$inter", Icons.public),
              _buildMetricItem("Wins", "$top3", Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value?.toString() ?? "-"),
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
