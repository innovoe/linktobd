import 'package:flutter/material.dart';
import 'package:link2bd/model/memory.dart';

class PlatformHome extends StatefulWidget {
  const PlatformHome({Key? key}) : super(key: key);

  @override
  State<PlatformHome> createState() => _PlatformHomeState();
}

class _PlatformHomeState extends State<PlatformHome> {
  int? selectedPlatform;
  int platformIdSelected = 1;
  final platforms = [
    {
      'id': 0,
      'title': 'Networking & Socialization',
      'icon': Icons.group,
      'image': 'assets/networking.png',
      'subtitle': 'Forge meaningful connections and expand your social horizon.',
      'description': 'Dive into a vibrant community where you can connect with like-minded individuals. Share experiences, attend events, and grow your network. Join us and amplify your social journey with people from around the globe.'
    },
    {
      'id': 1,
      'title': 'Business & Entrepreneurship',
      'icon': Icons.business,
      'image': 'assets/business.png',
      'subtitle': 'Empower your entrepreneurial spirit and discover new business ventures.',
      'description': 'Become a part of a thriving ecosystem of innovators and business enthusiasts. Share ideas, collaborate on projects, and get insights from seasoned entrepreneurs. Join the community and turn your business dreams into reality.'
    },
    {
      'id': 2,
      'title': 'Marriage & Dating',
      'icon': Icons.favorite,
      'image': 'assets/marriage.png',
      'subtitle': 'Find your partner in a community of genuine connections.',
      'description': 'Navigate your journey to love within a supportive community. Engage in meaningful conversations, find potential partners who align with your values, and build genuine relationships. Your perfect match might just be a click away.'
    },
    {
      'id': 3,
      'title': 'Travel & Hosting',
      'icon': Icons.travel_explore,
      'image': 'assets/travel.png',
      'subtitle': 'Unleash your wanderlust and explore destinations with local insights.',
      'description': 'Discover the world through the eyes of local enthusiasts. Share your travel tales, host travelers, or get tips for your next adventure. Join the community and embark on journeys filled with unique experiences.'
    },
    {
      'id': 4,
      'title': 'Study Abroad & Scholarship',
      'icon': Icons.school,
      'image': 'assets/study.png',
      'subtitle': 'Unlock global educational opportunities and broaden your academic pursuits.',
      'description': 'Step into a world of academic opportunities with our community. Connect with students, alumni, and mentors from across the globe. Share experiences, find scholarships, and get guidance on your educational journey. Together, we learn and grow.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    final platform = platforms[memory.platformId];
    return Scaffold(
      appBar: AppBar(
        title: Text(platform['title'] as String),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(platform['image'] as String),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(platform['subtitle'] as String),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(platform['description'] as String),
            ),
            ElevatedButton(
              onPressed: () {
                platformIdSelected = platform['id'] as int;
                memory.platformId = platformIdSelected;
                showAlertDialog(context, 'You are about to join the ${platform['title']} platform. Are you sure?');
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Join Platform'),
            ),
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
            child: Text('Yes take me there.'),
            onPressed: () {
              memory.platformId = platformIdSelected;
              Navigator.of(ctx).pop(); // Close the alert dialog
              Navigator.pushNamed(context, '/platform_home');
            },
          ),
          TextButton(
            child: Text('Nope, changed my mind.'),
            onPressed: () {
              memory.platformId = platformIdSelected;
              Navigator.of(ctx).pop(); // Close the alert dialog
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
