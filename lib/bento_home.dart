import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec
import 'theme_constants.dart';
import 'bento_card.dart';
import 'github_service.dart';

class BentoHome extends StatefulWidget {
  final String username; // Pass username here

  const BentoHome({Key? key, required this.username}) : super(key: key);

  @override
  State<BentoHome> createState() => _BentoHomeState();
}

class _BentoHomeState extends State<BentoHome> {
  late Future<GithubData> _futureData;
  final GithubService _service = GithubService();

  @override
  void initState() {
    super.initState();
    _futureData = _service.fetchGithubData(widget.username);
  }

  // Helper to open links
  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.scaffoldBg,
      body: FutureBuilder<GithubData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ThemeConstants.accentColor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final user = snapshot.data!.user;
            final repos = snapshot.data!.repos;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // --- 1. PROFILE IMAGE (Large, Top) ---
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ThemeConstants.accentColor, width: 3),
                      boxShadow: [BoxShadow(color: ThemeConstants.accentColor.withValues(alpha: .3), blurRadius: 20)],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user['avatar_url']),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- 2. NAME & USERNAME ---
                  Text(
                    user['name'] ?? "No Name",
                    style: ThemeConstants.titleStyle.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "@${user['login']}",
                    style: ThemeConstants.subtitleStyle.copyWith(color: ThemeConstants.accentColor),
                  ),
                  const SizedBox(height: 16),

                  // --- 3. BIO ---
                  if (user['bio'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        user['bio'],
                        style: ThemeConstants.bioStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // --- 4. LOCATION (City, Country with GPS Icon) ---
                  if (user['location'] != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          user['location'],
                          style: ThemeConstants.subtitleStyle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),

                  // --- 5. CONNECTIONS (GitHub, Email, Blog) ---
                  // Using a Row of Bento Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildConnectionCard(
                          icon: FontAwesomeIcons.github,
                          label: "GitHub",
                          color: Colors.black, // Github color
                          onTap: () => _launchUrl(user['html_url']),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (user['email'] != null) ...[
                        Expanded(
                          child: _buildConnectionCard(
                            icon: Icons.email,
                            label: "Email",
                            color: Colors.blue,
                            onTap: () => _launchUrl("mailto:${user['email']}"),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (user['blog'] != null && user['blog'].toString().isNotEmpty)
                        Expanded(
                          child: _buildConnectionCard(
                            icon: Icons.link,
                            label: "Website",
                            color: Colors.purple,
                            onTap: () => _launchUrl(user['blog'].startsWith('http') ? user['blog'] : 'https://${user['blog']}'),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft, child: Text("Top Projects", style: ThemeConstants.titleStyle)),
                  const SizedBox(height: 12),

                  // --- 6. TOP 7 PROJECTS (Horizontal Scroll) ---
                  SizedBox(
                    height: 180, // Height of the horizontal list
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: repos.length,
                      itemBuilder: (context, index) {
                        final repo = repos[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: BentoCard(
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(FontAwesomeIcons.bookBookmark, color: Colors.white54, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            repo['name'], 
                                            style: ThemeConstants.titleStyle.copyWith(fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      repo['description'] ?? "No description provided.",
                                      style: ThemeConstants.bioStyle.copyWith(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                        const SizedBox(width: 4),
                                        Text("${repo['stargazers_count']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 12),
                                        CircleAvatar(backgroundColor: _getLanguageColor(repo['language']), radius: 5),
                                        const SizedBox(width: 4),
                                        Text(repo['language'] ?? "N/A", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => _launchUrl(repo['html_url']),
                                      icon: const Icon(Icons.arrow_outward, color: ThemeConstants.accentColor),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 7. FOOTER (Connect with me Box) ---
                  BentoCard(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Connect with me", style: ThemeConstants.titleStyle.copyWith(fontSize: 18)),
                        const SizedBox(height: 10),
                        const Text(
                          "Open to collaborations and freelance work. Check out my repositories for more details.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () => _launchUrl(user['html_url']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.accentColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("View Full Profile on GitHub", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // Small helper widget for the Connections row
  Widget _buildConnectionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: BentoCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: color == Colors.black ? Colors.white : color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Helper for language dot colors
  Color _getLanguageColor(String? language) {
    if (language == null) return Colors.grey;
    switch (language.toLowerCase()) {
      case 'dart': return Colors.blue;
      case 'python': return Colors.yellow;
      case 'javascript': return Colors.amber;
      case 'html': return Colors.orange;
      case 'css': return Colors.blueAccent;
      default: return ThemeConstants.accentColor;
    }
  }
}