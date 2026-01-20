import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart'; 
import 'package:url_launcher/url_launcher.dart';
// REMOVED: import 'package:intl/intl.dart'; <-- This was causing your error

class BentoHome extends StatefulWidget {
  final String username;
  const BentoHome({super.key, required this.username});

  @override
  State<BentoHome> createState() => _BentoHomeState();
}

class _BentoHomeState extends State<BentoHome> {
  Map profile = {};
  List repos = [];
  List events = [];
  bool loading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userRes = await http.get(Uri.parse("https://api.github.com/users/${widget.username}"));
      final repoRes = await http.get(Uri.parse("https://api.github.com/users/${widget.username}/repos?per_page=100"));
      final eventRes = await http.get(Uri.parse("https://api.github.com/users/${widget.username}/events?per_page=10"));

      if (userRes.statusCode == 200 && repoRes.statusCode == 200) {
        setState(() {
          profile = json.decode(userRes.body);
          repos = json.decode(repoRes.body);
          events = json.decode(eventRes.body);
          loading = false;
        });
      } else {
        setState(() { loading = false; hasError = true; });
      }
    } catch (e) {
      setState(() { loading = false; hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(backgroundColor: Color(0xFF0E0E13), body: Center(child: CircularProgressIndicator()));
    if (hasError) return const Scaffold(backgroundColor: Color(0xFF0E0E13), body: Center(child: Text("User not found", style: TextStyle(color: Colors.white))));

    Map<String, int> langCount = {};
    for (var r in repos) {
      if (r["language"] != null) langCount[r["language"]] = (langCount[r["language"]] ?? 0) + 1;
    }
    final topLangs = langCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topRepos = repos..sort((a, b) => (b["stargazers_count"] ?? 0).compareTo(a["stargazers_count"] ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E13),
      appBar: AppBar(title: Text("@${widget.username}"), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              
              // 1. PROFILE CARD + STATS
              _card(
                Column(
                  children: [
                    CircleAvatar(radius: 40, backgroundImage: NetworkImage(profile["avatar_url"])),
                    const SizedBox(height: 10),
                    Text(profile["name"] ?? widget.username, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(profile["bio"] ?? "Dev", style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem("Repos", "${profile['public_repos']}"),
                        _statItem("Followers", "${profile['followers']}"),
                        _statItem("Following", "${profile['following']}"),
                      ],
                    )
                  ],
                ),
              ),

              // 2. RECENT ACTIVITY TABLE
              if (events.isNotEmpty)
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: .05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      const SizedBox(height: 10),
                      ...events.take(5).map((e) {
                        String type = e['type'];
                        String repoName = e['repo']['name'].toString().split('/').last;
                        
                        // FIXED: Manual String Date Logic (No Package Needed)
                        String date = "Unknown";
                        if (e['created_at'] != null && e['created_at'].toString().length >= 10) {
                           date = e['created_at'].toString().substring(0, 10);
                        }

                        if (type == 'PushEvent') type = '🚀 Pushed';
                        else if (type == 'WatchEvent') type = '⭐ Starred';
                        else if (type == 'CreateEvent') type = '🆕 Created';
                        else if (type == 'PullRequestEvent') type = '🔀 PR';
                        else type = '📝 Activity';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(type, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 100,
                                    child: Text(repoName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              Text(date, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              // 3. CHART CARD
              if (topLangs.isNotEmpty)
                _card(
                  SizedBox(
                    width: 300, height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topLangs.take(5).length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Transform.rotate(
                                  angle: -0.3, 
                                  child: Text(topLangs[value.toInt()].key, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                ),
                              );
                            }),
                          ),
                        ),
                        barGroups: List.generate(topLangs.take(5).length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: topLangs[i].value.toDouble(), color: Colors.blueAccent, width: 14, borderRadius: BorderRadius.circular(4))])),
                      ),
                    ),
                  ),
                ),

              // 4. TOP PROJECTS LIST
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Top Projects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    ...topRepos.take(5).map((r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r["name"], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(r["language"] ?? "Code", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward, size: 14, color: Colors.white30),
                      onTap: () => launchUrl(Uri.parse(r["html_url"])),
                    ))
                  ],
                ),
              ),

              // 5. CONNECT CARD
              _card(
                Column(
                  children: [
                    const Text("Connect", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(profile["html_url"])),
                      child: const Text("View GitHub Profile", style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: 320, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A22), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: child,
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}