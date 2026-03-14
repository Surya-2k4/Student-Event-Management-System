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

  // Modern Tech Palette
  final Color bgColor = const Color(0xFFF4F6F9);
  final Color primaryDark = const Color(0xFF0F172A);
  final Color secondaryDark = const Color(0xFF1E293B);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color textPrimary = const Color(0xFF1E293B);
  final Color textSecondary = const Color(0xFF64748B);

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
        title: const Text("Achievement Archive", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
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
            child: IconButton(icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 20), onPressed: _fetchEvents),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentBlue, strokeWidth: 3))
          : events.isEmpty
              ? _buildEmptyState()
              : ResponsiveLayout(
                  mobile: _buildList(crossAxisCount: 1),
                  desktop: _buildList(crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Icon(Icons.layers_clear_rounded, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 30),
          Text("Repository Empty", style: TextStyle(fontSize: 22, color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text("No achievement records indexed yet.\nInitiate a sync or submit a new entry.", textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildList({required int crossAxisCount}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 26, decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  Text("Indexed Records", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: textPrimary, letterSpacing: -0.5)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text("${events.length}", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.1, // make cards taller
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
    final String title = event['eventName'] ?? event['symposiumName'] ?? "Achievement Record";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.workspace_premium_rounded, color: accentBlue, size: 24),
            ),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary, letterSpacing: -0.5)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text("${event['college'] ?? 'N/A'} • ${event['eventDate'] ?? 'Unknown'}", style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            iconColor: accentBlue,
            children: [
              Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Participant", event['name'], Icons.person_outline),
                    _buildDetailRow("Identifier", event['rollNumber'], Icons.badge_outlined),
                    _buildDetailRow("Category", event['eventType'], Icons.category_outlined),
                    _buildDetailRow("Standing", event['positionSecured'], Icons.emoji_events_outlined),
                    _buildDetailRow("Scope", event['interOrIntraEvent'], Icons.public_outlined),
                    const SizedBox(height: 24),
                    if (event['certificationLink'] != null && event['certificationLink'].toString().isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                          label: const Text("Examine Proof", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 14))),
          const Text(" :  ", style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(value ?? "-", style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14))),
        ],
      ),
    );
  }
}
