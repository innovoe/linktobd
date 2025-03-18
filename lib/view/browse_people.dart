// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/custom_page_route_animator.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/people_model.dart';
import 'package:linktobd/model/widgets.dart';
import 'package:linktobd/view/comment_reply.dart';
import 'package:linktobd/view/person_profile.dart';

class BrowsePeople extends StatefulWidget {
  dynamic peopleList;
  int keyIndex;
  BrowsePeople({super.key, this.peopleList, required this.keyIndex});

  @override
  State<BrowsePeople> createState() => _BrowsePeopleState();
}

class _BrowsePeopleState extends State<BrowsePeople> {

  var listOfPeople;
  String currentIndex = '';
  int nextKeyIndex = 0;

  @override
  void initState() {
    super.initState();
    if(widget.peopleList == null){
      setData();
    }else{
      listOfPeople = widget.peopleList;
      var keys = listOfPeople.keys.toList();
      currentIndex = keys[widget.keyIndex];
      // Check if the current index is the last one
      nextKeyIndex = (widget.keyIndex + 1 < keys.length) ? widget.keyIndex + 1 : -1;
    }
  }



  @override
  Widget build(BuildContext context) {
    if(listOfPeople == null){
      return Center(child: CircularProgressIndicator(),);
    }else{
      var person = listOfPeople[currentIndex];
      Color primaryColor = Theme.of(context).primaryColor;
      return GestureDetector(
        onTap: (){},
        onVerticalDragUpdate: (details){
          if(details.delta.dy > 0){
            // showAlertDialog(context, 'down.', 'dragged!');
          }else{
            // showAlertDialog(context, 'up.', 'dragged!');
            Navigator.of(context).push(
                CustomPageRouteAnimator(child: PersonDetails(personJson: person,), direction: 'fromBottom')
            );
          }
        },
        onHorizontalDragUpdate: (details){
          if (details.delta.dx > 0) {
            if(nextKeyIndex == 1){
              Navigator.pushReplacementNamed(context, '/feed');
            }else{
              Navigator.pop(context);
            }
          }else{
            if(nextKeyIndex == -1){
              showAlertDialog(context, 'No other people matched at this moment.', 'Sorry!');
            }else{
              Navigator.of(context).push(
                  CustomPageRouteAnimator(child: BrowsePeople(peopleList: listOfPeople, keyIndex: nextKeyIndex), direction: 'fromRight')
              );
            }
          }
        },
        child: Scaffold(
          drawer: AppDrawer(currentRouteName: '/feed'),
          appBar: BadgeAppBar(title: memory.platformName),
          body: Column(
            children: [
              Row(
                children: [
                  topMenuItem(context, 'Feed', '/feed'),
                  topMenuItem(context, 'People', '/browse_people', true),
                  topMenuItem(context, 'Messages', '/messages')
                ],
              ),
              Container(color: primaryColor, height: 1,),
              Expanded(
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider('https://linktobd.com/assets/user_dp/${person['photo']}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay at the bottom
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 300, // Adjust the height of the gradient overlay
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text Information
                    Positioned(
                      bottom: 10, // Position from the bottom of the screen
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person['nickname'],
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          // SizedBox(height: 10,),
                          Text(
                            person['occupation'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            person['city'],
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

  }

  Future<void> setData() async{
    PeopleModel peopleModel = PeopleModel();
    var fetchedData = await peopleModel.getPeopleList();
    // print(fetchedData);
    listOfPeople = fetchedData;
    var keys = listOfPeople.keys.toList();

    if (keys.isNotEmpty) {
      currentIndex = keys[0];
      // Check if more than one key exists
      nextKeyIndex = (keys.length > 1) ? 1 : -1;
    }else{
      currentIndex = 'none';
      nextKeyIndex = -1; // Indicates no next item
    }
    setState(() {});
  }


}



