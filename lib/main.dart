import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Required to remove the '#' from URL
import 'bento_home.dart';
import 'creator_screen.dart';

void main() {
  // 1. This function removes the hash (#) from the URL.
  // URLs will look like "folio.app/kevin" instead of "folio.app/#/kevin"
  usePathUrlStrategy();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio.QR',
      debugShowCheckedModeBanner: false,
      
      // Define the dark theme for the whole app
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F13),
        // You can customize more global theme settings here if needed
      ),

      // 2. THE ROUTER: This decides which screen to show based on the browser URL
      onGenerateRoute: (settings) {
        
        // CASE A: The user is at the root URL (e.g., "folio-qr.web.app/")
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(
            builder: (_) => const CreatorScreen(),
          );
        }

        // CASE B: The user is at a profile URL (e.g., "folio-qr.web.app/kevin")
        // We need to strip the leading slash "/" to get the username "kevin"
        final uri = Uri.parse(settings.name!);
        if (uri.pathSegments.isNotEmpty) {
          final username = uri.pathSegments.first;
          
          // Return the BentoHome screen with the extracted username
          return MaterialPageRoute(
            builder: (_) => BentoHome(username: username),
          );
        }

        // FALLBACK: If something goes wrong, just show the Creator Screen
        return MaterialPageRoute(
          builder: (_) => const CreatorScreen(),
        );
      },
    );
  }
}