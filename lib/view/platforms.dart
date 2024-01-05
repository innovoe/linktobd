import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/memory.dart';

class Platforms extends StatefulWidget {
  const Platforms({Key? key}) : super(key: key);

  @override
  State<Platforms> createState() => _PlatformsState();
}

class _PlatformsState extends State<Platforms> {
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
      drawer: AppDrawer(currentRouteName: '/platforms',),
      appBar: AppBar(
        title: Text('Choose a Platform'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("As a new user, you are granted access to one group for free initially. To join additional groups, a fee will be required. Please choose your first group with care and make sure it aligns with your primary interest!"),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final platform = platforms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      elevation: selectedPlatform == index ? 10 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPlatform = index;
                          });
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0), // The desired top-left corner radius
                                topRight: Radius.circular(8.0), // The desired top-right corner radius
                              ),
                              child: Image.asset(platform['image'] as String, width: double.infinity, height: 120, fit: BoxFit.cover),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.all(15),
                              title: Row(
                                children: [
                                  Icon(platform['icon'] as IconData, size: 20),
                                  SizedBox(width: 5),
                                  Expanded(child: Text(platform['title'] as String, style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Opacity(
                                    opacity: 0.0,
                                    child: Icon(platform['icon'] as IconData, size: 20),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(child:Text(platform['subtitle'] as String),),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  platformIdSelected = platform['id'] as int;
                                  memory.platformId = platformIdSelected;
                                  showAlertDialog(context, 'Joining ${platform['title']} \n Remember only first one is free.');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                child: Text('Join'),
                              ),
                            ),
                          ],
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

  void showAlertDialog(BuildContext context, String message, [String title = '']) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: title == '' ? Text('Important!') : Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Let\'s Go'),
            onPressed: () {
              memory.platformId = platformIdSelected;
              Navigator.of(ctx).pop(); // Close the alert dialog
              Navigator.pushNamed(context, '/platform_home');
            },
          ),
        ],
      ),
    );
  }
}
