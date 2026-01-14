import 'package:flutter/material.dart';
import 'bento_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio.QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      // You can change 'octocat' or 'mralexgray' to your own github username to test
      home: const BentoHome(username: 'kevin15'), 
    );
  }
}