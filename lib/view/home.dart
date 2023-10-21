import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            homeButton(context, '/reportIssue', 'Report An Issue', Icons.camera_alt_outlined),
            homeButton(context, '/issueFeed', 'Issue Feed', Icons.list_alt),
            homeButton(context, '/myIssues', 'My Issues', Icons.book_outlined),
          ],
        ),
      ),
    );
  }

  Widget homeButton(BuildContext context, routeName, String text, IconData theIcon){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: OutlinedButton(
        onPressed: (){
          Navigator.pushNamed(context, routeName);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(theIcon),
              Text(text),
              Visibility(visible: false, child: Icon(theIcon))
            ],
          ),
        ),
      ),
    );
  }

}
