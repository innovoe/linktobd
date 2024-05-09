import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class RelativeTimestamp extends StatefulWidget {
  final String timestamp; // Unix timestamp in seconds
  final String serverTimezoneName; // IANA timezone name of the server, e.g., "Europe/Zurich"
  final double fontSize;
  // Set "Europe/Zurich" as the default timezone
  RelativeTimestamp({
    required this.timestamp,
    this.serverTimezoneName = "Europe/Zurich",
    this.fontSize = 16
  });

  @override
  _RelativeTimestampState createState() => _RelativeTimestampState();
}

class _RelativeTimestampState extends State<RelativeTimestamp> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimestamp() {
    int serverTimestamp = int.parse(widget.timestamp);
    tz.TZDateTime serverDateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.getLocation(widget.serverTimezoneName),
      serverTimestamp * 1000,
    );

    // Convert UTC time to the user's local timezone
    tz.TZDateTime localDateTime = tz.TZDateTime.from(
        serverDateTime,
        tz.local
    );

    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    Duration difference = now.difference(localDateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes == 1) {
      return '1 minute ago'; // Singular form for one minute
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago'; // Plural form for more than one minute
    } else if (difference.inHours == 1) {
      return '1 hour ago'; // Singular form for one hour
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago'; // Plural form for more than one hour
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat("hh:mm a").format(localDateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat("EEEE 'at' hh:mm a").format(localDateTime);
    } else {
      return DateFormat("MMM d, yyyy 'at' hh:mm a").format(localDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTimestamp(),
      style: TextStyle(fontSize: widget.fontSize),
    );
  }
}
