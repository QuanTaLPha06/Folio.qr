import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubData {
  final Map<String, dynamic> user;
  final List<dynamic> repos;

  GithubData({required this.user, required this.repos});
}

class GithubService {
  final String baseUrl = "https://api.github.com/users";

  Future<GithubData> fetchGithubData(String username) async {
    // 1. Fetch User Profile
    final userResponse = await http.get(Uri.parse('$baseUrl/$username'));
    
    // 2. Fetch Repositories
    final repoResponse = await http.get(Uri.parse('$baseUrl/$username/repos?sort=updated&per_page=100'));

    if (userResponse.statusCode == 200 && repoResponse.statusCode == 200) {
      List<dynamic> allRepos = json.decode(repoResponse.body);
      
      // Sort by stars descending and take top 7
      allRepos.sort((a, b) => (b['stargazers_count'] ?? 0).compareTo(a['stargazers_count'] ?? 0));
      List<dynamic> topRepos = allRepos.take(7).toList();

      return GithubData(
        user: json.decode(userResponse.body),
        repos: topRepos,
      );
    } else {
      throw Exception('Failed to load GitHub data');
    }
  }
}