import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
<<<<<<< Updated upstream
  String email = "";
=======
  String userRole = "";
  String userEmail = "";

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
<<<<<<< Updated upstream
    setState(() {
      email = prefs.getString("email") ?? "";
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
        setState(() {
          events = json.decode(response.body).reversed.toList();
          filteredEvents = events;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
=======
    String token = prefs.getString("token") ?? "";
    String role = prefs.getString("role")?.toLowerCase() ?? "";
    String email = prefs.getString("email") ?? "";
    
    // If no token, return to login
    if (token.isEmpty) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }

    setState(() {
      userRole = role;
      userEmail = email;
    });

    // Handle browser refresh (F5): If this is the root of the stack, locate to dashboard
    if (mounted) {
      Future.microtask(() {
        if (mounted && !Navigator.canPop(context)) {
          String targetRoute = (role == "admin" || role == "staff") ? "/admin" : "/user_screen";
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      });
    }

    // Role-based diagnostics
    if (role.isNotEmpty && role != "admin" && role != "student") {
      debugPrint("Unauthorized access to reports attempt for role: $role");
    }
    
    fetchEvents(email: role == "student" ? email : null);
  }

  Future<void> fetchEvents({String? email, Map<String, String>? filters}) async {
    setState(() => isLoading = true);
    try {
      final fetchedEvents = await EventService().fetchEvents(email: email, filters: filters);
>>>>>>> Stashed changes
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching events: $e");
    }
  }

  void filterEvents() async {
    final queryParameters = {
      if (!email.endsWith('@kongu.ac.in')) 'email': email,
      'year': yearController.text,
      'symposiumName': searchController.text,
      'college': collegeController.text,
      'interOrIntraEvent': eventType == 'None' ? '' : eventType,
      'position': position == 'None' ? '' : position,
    };

    final uri = Uri.http('localhost:5000', '/view-events', queryParameters);

    try {
<<<<<<< Updated upstream
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          filteredEvents = json.decode(response.body);
        });
      } else {
        throw Exception("Failed to load filtered events");
      }
=======
      final fetchedEvents = await EventService().fetchEvents(
        email: userRole == "student" ? userEmail : null,
        filters: filters,
      );
      setState(() => filteredEvents = fetchedEvents);
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
    // Allow both admin and student roles to access the report screen
    if (userRole.isNotEmpty && userRole != "admin" && userRole != "student") {
      return const Scaffold(body: Center(child: Text("Access Restricted to Authorized Personnel")));
    }

>>>>>>> Stashed changes
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
<<<<<<< Updated upstream
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              // Fallback for browser refreshed state
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
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  Widget _buildDetailText(String label, dynamic value) {
=======
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
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
>>>>>>> Stashed changes
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
