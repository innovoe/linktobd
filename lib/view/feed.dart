import 'package:flutter/material.dart';
import 'package:link2bd/model/widgets.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/feed_card.dart';
import 'package:link2bd/model/app_drawer.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int? selectedPlatform;
  int platformIdSelected = 1;

  final feeds = [
    {
      'user_id':1,
      'user_name': 'Michael  De Santa',
      'user_photo': 'michael_de_santa.png',
      'post_time': '7:33PM 24/10/2023',
      'post_text': 'Trevor is the worst friend I ever had. And Franklin is the kid I never had.',
      'photos': [
        {0:'photo_1.jpg'},
        {0:'photo_2.jpg'},
        {0:'photo_3.jpg'},
        {0:'photo_4.jpg'}
      ],
      'like': 'true',
      'like_count': 150,
      'comment_count': 36
    },
    {
      'user_id': 2,
      'user_name': 'Franklin Clinton',
      'user_photo': 'franklin_clinton.png',
      'post_time': '10:15AM 25/10/2023',
      'post_text': 'Chop and I enjoying a beautiful morning walk. 🐶☀️',
      'photos': [
        {'0': 'photo_5.jpg'},
      ],
      'like': 'true',
      'like_count': 87,
      'comment_count': 22,
    },
    {
      'user_id': 3,
      'user_name': 'Trevor Philips',
      'user_photo': 'trevor_philips.png',
      'post_time': '2:45PM 25/10/2023',
      'post_text': 'Just another day at the airfield. Explosions and mayhem! 💥✈️',
      'photos': [
        {'0': 'photo_6.jpg'},
        {'1': 'photo_7.jpg'},
      ],
      'like': 'false',
      'like_count': 42,
      'comment_count': 12,
    },
    {
      'user_id': 4,
      'user_name': 'Lamar Davis',
      'user_photo': 'lamar_davis.png',
      'post_time': '6:30PM 25/10/2023',
      'post_text': 'Out on the streets hustlin\' and grindin\'! 💰🏙️',
      'photos': [
        {'0': 'photo_8.jpg'},
        {'1': 'photo_9.jpg'},
        {'2': 'photo_10.jpg'},
      ],
      'like': 'true',
      'like_count': 64,
      'comment_count': 18,
    },
    {
      'user_id': 5,
      'user_name': 'Amanda De Santa',
      'user_photo': 'amanda_de_santa.png',
      'post_time': '9:20AM 26/10/2023',
      'post_text': 'Morning yoga by the beach. Namaste! 🧘‍♀️🏖️',
      'photos': [
        {'0': 'photo_11.jpg'},
      ],
      'like': 'true',
      'like_count': 93,
      'comment_count': 25,
    },
    {
      'user_id': 6,
      'user_name': 'Wade Hebert',
      'user_photo': 'wade_hebert.png',
      'post_time': '3:55PM 26/10/2023',
      'post_text': 'Just found something weird in the desert. Any takers? 👽🌵',
      'photos': [
        {'0': 'photo_12.jpg'},
      ],
      'like': 'false',
      'like_count': 55,
      'comment_count': 10,
    },
    {
      'user_id': 7,
      'user_name': 'Tracey De Santa',
      'user_photo': 'tracey_de_santa.png',
      'post_time': '7:10PM 26/10/2023',
      'post_text': 'Ready for a night out with friends! 🎉🍸',
      'photos': [
        {'0': 'photo_13.jpg'},
      ],
      'like': 'true',
      'like_count': 78,
      'comment_count': 16,
    },
    {
      'user_id': 8,
      'user_name': 'Lester Crest',
      'user_photo': 'lester_crest.png',
      'post_time': '11:30AM 27/10/2023',
      'post_text': 'Working on some genius plans today! 💡📊',
      'photos': [
        {'0': 'photo_14.jpg'},
      ],
      'like': 'true',
      'like_count': 105,
      'comment_count': 30,
    },
    {
      'user_id': 9,
      'user_name': 'Jimmy De Santa',
      'user_photo': 'jimmy_de_santa.png',
      'post_time': '4:45PM 27/10/2023',
      'post_text': 'Gaming marathon with my buddies! 🎮🕹️',
      'photos': [
        {'0': 'photo_15.jpg'},
        {'1': 'photo_16.jpg'},
      ],
      'like': 'false',
      'like_count': 37,
      'comment_count': 8,
    },
    {
      'user_id': 10,
      'user_name': 'Chop (The Dog)',
      'user_photo': 'chop_the_dog.png',
      'post_time': '8:05PM 27/10/2023',
      'post_text': 'Just chillin\' and being the good boy that I am! 🐶😎',
      'photos': [
        {'0': 'photo_17.jpg'},
      ],
      'like': 'true',
      'like_count': 72,
      'comment_count': 20,
    },
    {
      'user_id': 11,
      'user_name': 'Ron Jakowski',
      'user_photo': 'ron_jakowski.png',
      'post_time': '10:40AM 28/10/2023',
      'post_text': 'Keeping an eye on things from my trailer. Always vigilant! 👀🏠',
      'photos': [
        {'0': 'photo_18.jpg'},
      ],
      'like': 'false',
      'like_count': 51,
      'comment_count': 15,
    },
    {
      'user_id': 12,
      'user_name': 'Molly Schultz',
      'user_photo': 'molly_schultz.png',
      'post_time': '2:20PM 28/10/2023',
      'post_text': 'Corporate life isn\'t so bad, right? 💼🏢',
      'photos': [
        {'0': 'photo_19.jpg'},
      ],
      'like': 'true',
      'like_count': 62,
      'comment_count': 14,
    },
  ];



  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/feed'),
      appBar: AppBar(
        title: Text(memory.platformName),
      ),
      body: Column(
        children: [
          Row(
            children: [
              topMenuItem(context, 'Feed', '/feed', true),
              topMenuItem(context, 'People', '/profile_view'),
              topMenuItem(context, 'Messages', '/messages')
            ],
          ),
          Container(color: primaryColor, height: 1,),
          Expanded(
            child: ListView(
              children: feeds.map((feedData) => FeedCard(feedData: feedData)).toList(),
            ),
          ),
        ],
      ),
    );
  }




}
