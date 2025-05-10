import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Add this import
import 'auth/profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String latestAlert = "Loading...";
  String alertTime = "";
  RealtimeChannel? alertChannel;
  List<Map<String, dynamic>> alertRecords = [];

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    subscribeToAlerts();
  }

  @override
  void dispose() {
    alertChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    final response = await Supabase.instance.client
        .from('alerts')
        .select('level, timestamp')
        .order('timestamp', ascending: false)
        .execute();

    final data = response.data;
    if (data != null && data.isNotEmpty) {
      setState(() {
        alertRecords = List<Map<String, dynamic>>.from(data);
        final latestData = data[0];
        latestAlert = latestData['level'];
        alertTime = formatTimestamp(latestData['timestamp']);
      });
    } else {
      setState(() {
        latestAlert = "No data yet";
        alertTime = "";
        alertRecords.clear();
      });
    }
  }

  void subscribeToAlerts() {
    final channel = Supabase.instance.client.channel('public:alerts');

    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'alerts'),
          (payload, [ref]) {
        final newData = payload['new'];
        if (newData != null && newData['level'] != null) {
          setState(() {
            latestAlert = newData['level'];
            alertTime = formatTimestamp(newData['timestamp']);
            alertRecords.insert(0, newData);
          });
        }
      },
    );

    channel.subscribe();
    alertChannel = channel;
  }

  String formatTimestamp(String timestamp) {
    final dateTimeUtc = DateTime.parse(timestamp).toUtc();
    final localDateTime = dateTimeUtc.toLocal();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(localDateTime);
  }

  Color getAlertColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green.shade100;
      case 'medium':
        return Colors.orange.shade200;
      case 'high':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  Icon getAlertIcon(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'medium':
        return Icon(Icons.warning, color: Colors.orange);
      case 'high':
        return Icon(Icons.dangerous, color: Colors.red);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String getAlertMessage(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return "LOW Water Level: No immediate danger.";
      case 'medium':
        return "MEDIUM Water Level: Stay alert!";
      case 'high':
        return "WARNING! HIGH Water Level Detected! Possible Flooding!";
      default:
        return "No alert available.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SmartFlood',
          style: TextStyle(color: Colors.white), // Set title text color to white
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to ProfilePage
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: getAlertColor(latestAlert),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    getAlertIcon(latestAlert),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Latest Alert:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(getAlertMessage(latestAlert), style: TextStyle(fontSize: 20)),
                          Text('Time: $alertTime', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: alertRecords.isEmpty
                  ? Center(child: Text('No alert history yet'))
                  : ListView.builder(
                itemCount: alertRecords.length,
                itemBuilder: (context, index) {
                  final alert = alertRecords[index];
                  final level = alert['level'] ?? 'Unknown';
                  return Card(
                    color: getAlertColor(level),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: getAlertIcon(level),
                      title: Text(getAlertMessage(level), style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(formatTimestamp(alert['timestamp'])),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
