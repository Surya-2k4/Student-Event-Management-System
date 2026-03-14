import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:flutter_auth/services/event_services.dart';
import 'package:flutter_auth/utils/responsive_layout.dart';

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
  String userEmail = "";

  // Modern Tech Palette
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color primaryDark = const Color(0xFF0F172A);
  final Color secondaryDark = const Color(0xFF1E293B);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color accentIndigo = const Color(0xFF4F46E5);
  final Color textPrimary = const Color(0xFF1E293B);
  final Color textSecondary = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    String role = prefs.getString("role")?.toLowerCase() ?? "";
    String email = prefs.getString("email") ?? "";
    
    if (token.isEmpty) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }

    setState(() {
      userRole = role;
      userEmail = email;
    });

    if (mounted) {
      Future.microtask(() {
        if (mounted && !Navigator.canPop(context)) {
          String targetRoute = (role == "admin" || role == "staff") ? "/admin" : "/user_screen";
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      });
    }

    if (role.isNotEmpty && role != "admin" && role != "student") {
      debugPrint("Unauthorized access to reports attempt for role: $role");
    }
    
    fetchEvents(email: role == "student" ? email : null);
  }

  Future<void> fetchEvents({String? email, Map<String, String>? filters}) async {
    setState(() => isLoading = true);
    try {
      final fetchedEvents = await EventService().fetchEvents(email: email, filters: filters);
      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("Error fetching events: $e");
    }
  }

  void filterEvents() async {
    final queryParameters = {
      if (!userEmail.endsWith('@kongu.ac.in')) 'email': userEmail,
      'year': yearController.text,
      'symposiumName': searchController.text,
      'college': collegeController.text,
      'interOrIntraEvent': eventType == 'None' ? '' : eventType,
      'position': position == 'None' ? '' : position,
    };

    try {
      final fetchedEvents = await EventService().fetchEvents(
        email: userRole == "student" ? userEmail : null,
        filters: queryParameters,
      );
      setState(() => filteredEvents = fetchedEvents);
    } catch (e) {
      debugPrint("Error fetching filtered events: $e");
    }
  }

  Future<void> downloadReport() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Compiling PDF Payload..."),
      backgroundColor: accentBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Analytical Insights Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  "Participant", "Email", "Institution", "Roll No", "Symposium", "Type", "Event Scope", "Prize"
                ],
                data: filteredEvents.map((event) {
                  return [
                    event["name"]?.toString() ?? "-",
                    event["email"]?.toString() ?? "-",
                    event["college"]?.toString() ?? "-",
                    event["rollNumber"]?.toString() ?? "-",
                    event["symposiumName"]?.toString() ?? "-",
                    event["eventType"]?.toString() ?? "-",
                    event["interOrIntraEvent"]?.toString() ?? "-",
                    event["positionSecured"]?.toString() ?? "-",
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("PDF Export Successful\nPath: $path"),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 5),
    ));
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
    if (userRole.isNotEmpty && userRole != "admin" && userRole != "student") {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 80, color: Colors.redAccent.withOpacity(0.8)),
              const SizedBox(height: 20),
              Text("Access Restricted", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 8),
              Text("Clearance required to view reports.", style: TextStyle(fontSize: 16, color: textSecondary)),
            ],
          ),
        ),
      );
    }

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
        title: const Text("Analytical Reports", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryDark, secondaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 20), onPressed: () => fetchEvents()),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentBlue, strokeWidth: 3))
          : ResponsiveLayout(
              mobile: _buildMobileView(),
              desktop: _buildDesktopView(),
            ),
    );
  }

  Widget _buildMobileView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMobileFilters(),
          const SizedBox(height: 30),
          _buildOverviewDashboard(filteredEvents),
          const SizedBox(height: 20),
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_rounded, color: accentBlue, size: 24),
              const SizedBox(width: 10),
              Text("Query Filters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: filterEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text("Execute Filter Query", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                filterEvents();
                downloadReport();
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
              label: const Text("Export Payload (.pdf)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Sidebar
        Container(
          width: 380,
          color: Colors.white,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 20, offset: const Offset(10, 0))],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.filter_alt_rounded, color: accentBlue, size: 24)),
                    const SizedBox(width: 16),
                    Text("Query Builder", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5)),
                  ],
                ),
                const SizedBox(height: 35),
                _buildFilters(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: filterEvents,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryDark, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: const Text("Apply Pipeline Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () { filterEvents(); downloadReport(); },
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    label: const Text("Generate PDF Export", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                    child: const Text("Erase Query Parameters", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewDashboard(filteredEvents),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Data Pipeline Results", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text("${filteredEvents.length} Matched", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w700))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildResultsList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewDashboard(List<dynamic> events) {
    final int total = events.length;
    final int intra = events.where((e) => e['interOrIntraEvent'] == 'Intra').length;
    final int inter = events.where((e) => e['interOrIntraEvent'] == 'Inter').length;
    final int top3 = events.where((e) {
      final pos = int.tryParse(e['positionSecured']?.toString() ?? '');
      return pos != null && pos <= 3;
    }).length;

    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: primaryDark.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
        image: const DecorationImage(
          image: AssetImage('assets/mesh_bg.png'), // placeholder for complex gradients
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: const Text("Insight Telemetry", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0))),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$total", style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w800, height: 0.9, letterSpacing: -2)),
                        const SizedBox(width: 12),
                        const Padding(padding: EdgeInsets.only(bottom: 6), child: Text("Verified\nEntries", style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600, height: 1.2))),
                      ],
                    ),
                  ],
                ),
              ),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.hub_rounded, color: Colors.white, size: 40)),
            ],
          ),
          const SizedBox(height: 35),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem("Intra Node", "$intra", Icons.location_city_rounded),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildMetricItem("Inter Node", "$inter", Icons.public_rounded),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildMetricItem("Top Tier", "$top3", Icons.emoji_events_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        _buildInputField(searchController, "Symposium Entity", Icons.search_rounded),
        const SizedBox(height: 16),
        _buildInputField(collegeController, "Institution Domain", Icons.business_rounded),
        const SizedBox(height: 16),
        _buildInputField(yearController, "Batch Index", Icons.calendar_today_rounded),
        const SizedBox(height: 16),
        _buildDropdown("Operational Scope", eventType, ['None', 'Inter', 'Intra'], (v) => setState(() => eventType = v!)),
        const SizedBox(height: 16),
        _buildDropdown("Leaderboard Standing", position, ['None', '1', '2', '3'], (v) => setState(() => position = v!)),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: ctrl.text.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18), onPressed: () => _clearFilter(ctrl)) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentBlue, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      onChanged: (v) => setState(() {}),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIcon: Icon(Icons.layers_rounded, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accentBlue, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildResultsList() {
    if (filteredEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text("No matching queries", style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: primaryDark.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.person_rounded, color: primaryDark, size: 24),
              ),
              title: Text(event['name'] ?? "Unknown Operative", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textPrimary, letterSpacing: -0.5)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text("${event['eventName'] ?? 'Unknown Event'} • ${event['college'] ?? 'Unknown Location'}", style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              iconColor: primaryDark,
              children: [
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDataRow("Roll Number", event['rollNumber']),
                      _buildDataRow("Symposium", event['symposiumName']),
                      _buildDataRow("Final Standing", event['positionSecured']),
                      _buildDataRow("Participation Scope", event['interOrIntraEvent']),
                      _buildDataRow("Execution Date", event['eventDate']),
                      const SizedBox(height: 24),
                      if (event['certificationLink'] != null && event['certificationLink'].toString().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.link_rounded, size: 18),
                          label: const Text("Access Verification Proof", style: TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          const Text(" :  ", style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(value?.toString() ?? "-", style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14))),
        ],
      ),
    );
  }
}
