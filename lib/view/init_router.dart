import 'package:link2bd/model/login_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class InitRouter extends StatefulWidget {
  const InitRouter({Key? key}) : super(key: key);

  @override
  _InitRouterState createState() => _InitRouterState();
}


class _InitRouterState extends State<InitRouter> {

  String message = '';
  bool locked = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _navigateTo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                child: message == '' ? CircularProgressIndicator() : Text(message),
              ),
              SizedBox(height: 20),
              locked ? OutlinedButton(
                  child: Icon(Icons.refresh),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/');
                  }
              ) :
              ElevatedButton(
                child: Text('Let\'s Go!'),
                onPressed: () async{
                  // Navigator.pushReplacementNamed(context, '/my_platforms');
                  LoginModel loginModel = LoginModel();
                  int id = await loginModel.getId();
                  if(id == 0){
                    Navigator.pushReplacementNamed(context, '/login');
                  }else{
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                }
              )
            ],
          )
      ),
    );
  }

  void _navigateTo() async{
    if(await Permission.location.request().isGranted){
      if(await Geolocator.isLocationServiceEnabled()){
        try {
          var response = await Dio().get('https://linktobd.com/appapi/check_con');
          setState(() {
            message = response.data.toString();
            locked = false;
          });
        } catch (e) {
          setState(() {
            message = 'Internet Connection Down. $e.';
          });
        }
      }else{
        setState(() {
          message = 'Please turn on your devices location';
        });
      }
    }else{
      setState(() {
        message = 'Location Permission is needed to run the app';
      });
    }
  }
}

