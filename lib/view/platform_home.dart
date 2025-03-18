import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/memory.dart';

import '../model/user_model.dart';

class PlatformHome extends StatefulWidget {
  const PlatformHome({Key? key}) : super(key: key);

  @override
  State<PlatformHome> createState() => _PlatformHomeState();
}

class _PlatformHomeState extends State<PlatformHome> {
  String apiReturn = '';

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    UserModel userModel = UserModel();
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform Select'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: userModel.getAllPlatforms(),
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Text('Seems like an error occurred. Please try again.');
            } else if(snapshot.hasData){
              var platforms = snapshot.data;
              List<Widget> bodyFat = [Text('damn')];
              for(var platform in platforms) {
                if(platform['id'].toString() == memory.platformId.toString()){
                  bodyFat = [
                    Image.asset(platform['image'] as String),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(platform['title'] as String, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(platform['subtitle']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(platform['description'] as String),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(apiReturn, style: TextStyle(color: Colors.red),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          memory.platformId = int.parse(platform['id']);
                          showAlertDialog(context, 'You are about to join the ${platform['title']} platform. Are you sure?');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: Text('Join Platform'),
                      ),
                    ),
                  ];
                }
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bodyFat
              );


            }else{
              return CircularProgressIndicator();
            }

          },
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
            onPressed: () async{
              Navigator.of(ctx).pop(); // Close the alert dialog
              setState(() {apiReturn='Working on it. Please wait...';});
              Dio dio = Dio();
              final formData = FormData.fromMap({
                'token': memory.token.toString(),
                'platform_id' : memory.platformId.toString()
              });
              Response response = await dio.post(
                  'https://linktobd.com/appapi/platform_assign',
                  data: formData
              );
              var got = response.data;
              if(got['req'].toString() == 'no'){
                apiReturn = 'data post problem';
              }else if(got['existing'].toString() == 'yes'){
                apiReturn = 'You have already joined this platform';
              }else if(got['insert'].toString() == 'yes'){
                apiReturn = 'Success!';
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, '/feed');
              }
              setState(() {apiReturn;});
            },
          ),
          TextButton(
            child: Text('Nope, changed my mind.'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the alert dialog
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
