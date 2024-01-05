import 'package:flutter/material.dart';
import 'package:link2bd/model/memory.dart';


class MyPlatforms extends StatefulWidget {
  const MyPlatforms({Key? key}) : super(key: key);

  @override
  State<MyPlatforms> createState() => _MyPlatformsState();
}

class _MyPlatformsState extends State<MyPlatforms> {
  int? selectedPlatform;
  int platformIdSelected = 1;

  final platforms = [
    {
      'id':0,
      'title': 'Networking & Socialization',
      'icon': Icons.group,
      'image': 'assets/networking.png',
      'subtitle': 'Forge meaningful connections and expand your social horizon.'
    },
    {
      'id':1,
      'title': 'Business & Entrepreneurship',
      'icon': Icons.business,
      'image': 'assets/business.png',
      'subtitle': 'Empower your entrepreneurial spirit and discover new business ventures.'
    },
    {
      'id':2,
      'title': 'Marriage & Dating',
      'icon': Icons.favorite,
      'image': 'assets/marriage.png',
      'subtitle': 'Find your partner in a community of genuine connections.'
    },
    {
      'id':3,
      'title': 'Travel & Hosting',
      'icon': Icons.travel_explore,
      'image': 'assets/travel.png',
      'subtitle': 'Unleash your wanderlust and explore destinations with local insights.'
    },
    {
      'id':4,
      'title': 'Study Abroad & Scholarship',
      'icon': Icons.school,
      'image': 'assets/study.png',
      'subtitle': 'Unlock global educational opportunities and broaden your academic pursuits.'
    },
  ];


  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Platforms'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      color: primaryColor,
                      elevation: selectedPlatform == index ? 10 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          memory.platformId = index;
                          memory.platformName = platform['title'] as String;
                          Navigator.pushReplacementNamed(context, '/feed');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              Icon(platform['icon'] as IconData, size: 50),
                              Text(platform['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
