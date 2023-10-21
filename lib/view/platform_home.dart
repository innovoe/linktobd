import 'package:flutter/material.dart';
import 'package:link2bd/model/memory.dart';

class PlatformHome extends StatefulWidget {
  const PlatformHome({Key? key}) : super(key: key);

  @override
  State<PlatformHome> createState() => _PlatformHomeState();
}

class _PlatformHomeState extends State<PlatformHome> {
  final platforms = [
    {
      'id':1,
      'title': 'Networking & Socialization',
      'icon': Icons.group,
      'image': 'assets/networking.png',
      'subtitle': 'Forge meaningful connections and expand your social horizon.'
    },
    {
      'id':2,
      'title': 'Business & Entrepreneurship',
      'icon': Icons.business,
      'image': 'assets/business.png',
      'subtitle': 'Empower your entrepreneurial spirit and discover new business ventures.'
    },
    {
      'id':3,
      'title': 'Marriage & Dating',
      'icon': Icons.favorite,
      'image': 'assets/marriage.png',
      'subtitle': 'Find your partner in a community of genuine connections.'
    },
    {
      'id':4,
      'title': 'Travel & Hosting',
      'icon': Icons.travel_explore,
      'image': 'assets/travel.png',
      'subtitle': 'Unleash your wanderlust and explore destinations with local insights.'
    },
    {
      'id':5,
      'title': 'Study Abroad & Scholarship',
      'icon': Icons.school,
      'image': 'assets/study.png',
      'subtitle': 'Unlock global educational opportunities and broaden your academic pursuits.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final platform = platforms[memory.platformId];
    return Scaffold(
      appBar: AppBar(
        title: Text(platform['title'] as String),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(platform['image'] as String),
            Text(platform['subtitle'] as String),
          ],
        ),
      ),
    );
  }
}
