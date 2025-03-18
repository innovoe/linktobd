import 'package:flutter/material.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';

class ProfileCheck extends StatelessWidget {
  const ProfileCheck({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/profile_check'),
      appBar: BadgeAppBar(
        title: 'Profile Completion',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: userModel.profileCompletionCheck(),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Text('Error connecting the Server. ${snapshot.error.toString()}');
                }else if(snapshot.hasData){
                  Map<String, String> data = snapshot.data!;
                  if(data.isNotEmpty){
                    return Text(
                        'Your Profile is \n ${data['completion']}% \n Completed.',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    );
                  }else{
                    return Text('Something went wrong.');
                  }
                }else{
                  return CircularProgressIndicator();
                }
              }
            ),
            SizedBox(height: 20,),
            OutlinedButton(
              onPressed: (){},
              child: Text('Go to profile')
            )
          ],
        ),
      ),
    );
  }
}
