import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rpkgpjsogpjdbnqextwp.supabase.co', // Your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwa2dwanNvZ3BqZGJucWV4dHdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0MjM1NjQsImV4cCI6MjA2MTk5OTU2NH0.w1ss-EJtgyIeMMdDJctVuxIsvqbGXg2R-sK2hIsAAF4', // Your Supabase anon key
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFlood Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Show splash screen first
    );
  }
}
