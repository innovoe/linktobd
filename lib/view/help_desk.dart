import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/view/add_help_issue.dart';

import '../model/badge_appbar.dart';
import '../model/custom_page_route_animator.dart';

class HelpDesk extends StatefulWidget {
  const HelpDesk({super.key});

  @override
  State<HelpDesk> createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
  var primaryColor = Color(0xFFB533F1);

  Map<String, String> statusList = {
    '0': 'pending',
    '1': 'Processing',
    '2': 'Cancelled',
    '3': 'Resolved'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BadgeAppBar(title: 'Help Desk'),
      drawer: AppDrawer(currentRouteName: '/help_desk'),
      body: helpDeskBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
              CustomPageRouteAnimator(child: AddHelpIssue(setParentState: setHelpDeskState,), direction: 'fromRight')
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void setHelpDeskState(){
    setState(() {});
  }


  Widget helpDeskBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: getIssueList(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.hasData) {
              var issueList = snapshot.data as List<dynamic>; // Cast to List
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: issueList.map((issue) {
                  return issues(
                      issue['issue_id'].toString(),
                      int.parse(issue['photos'].toString()),
                      issue['description'].toString(),
                      issue['created'].toString(),
                      issue['status'].toString()
                  );
                }).toList(), // Convert iterable to List<Widget>
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future getIssueList() async {
    FormData formData = FormData.fromMap({'token': memory.token});
    Dio dio = Dio();
    try {
      var response = await dio.post(
        'https://linktobd.com/appapi/issue_list',
        data: formData,
      );
      return response.data; // Assuming data is the list of issues
    } catch (e) {
      print(e);
      return Future.error(e.toString());
    }
  }


  Widget issues(
      String issueId,
      int attachedImagesCount,
      String description,
      String created,
      String status
      )
  {
    DateTime parsedTime = DateTime.parse(created);
    String formattedTime = DateFormat('hh:mm a, d/m/y').format(parsedTime);
    String issueDisplayName = '${description.substring(0, 20)}...';
    String statusString = statusList[status] ?? 'Unknown Status';
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            // color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issueDisplayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Time of submission: $formattedTime',
            style: TextStyle(
              fontSize: 14,
              // color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Attached Images: $attachedImagesCount',
            style: TextStyle(
              fontSize: 14,
              // color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            description.length > 300
                ? '${description.substring(0, 180)}...'
                : description,
            style: TextStyle(
              fontSize: 14,
              // color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed: (){
                    memory.issueId = issueId;
                    Navigator.pushNamed(context, '/single_issue');
                  },
                  child: Text('Details')
              ),
              Text(statusString)
            ],
          )
        ],
      ),
    );
  }


}
