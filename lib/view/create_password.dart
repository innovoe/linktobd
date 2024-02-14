import 'package:link2bd/model/memory.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:dio/dio.dart';

class CreatePassword extends StatefulWidget {
  CreatePassword({Key? key}) : super(key: key);

  @override
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final introKey = GlobalKey<IntroductionScreenState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  bool isLoading = false;
  Widget output = Text('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 60),
              SizedBox(height: 10),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Create a password',
                    style: TextStyle(fontSize: 20),
                  )
              ),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: output
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  obscureText: true,
                  controller: passwordConfirmController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                ),
              ),

              SizedBox(height: 20),
              Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: Text('save my password'),
                    onPressed: () async {
                      setState(() {
                        output = CircularProgressIndicator();
                      });
                      if(passwordController.text.isEmpty || passwordConfirmController.text.isEmpty){
                        setState(() {
                          output = Text('Please fill up both the password fields carefully.');
                        });
                      }else if(passwordController.text != passwordConfirmController.text){
                        setState(() {
                          output = Text('Passwords didn\'t match. Please input carefully.');
                        });
                      }else{
                        FormData formData = FormData.fromMap({
                          'token' : memory.token,
                          'password': passwordController.text,
                        });
                        var dio = Dio();
                        try{
                          Response response = await dio.post(
                            'https://linktobd.com/appapi/create_password',
                            data: formData,
                          );
                          var respond = response.data;
                          if (response.statusCode == 200) {
                            if (mounted) {
                              if (respond['success'].toString() == 'yes') {
                                output = Text('Password saved.');
                                Future.delayed(const Duration(seconds: 1)).then((val) {
                                  Navigator.pushReplacementNamed(context, '/my_platforms');
                                });
                              }
                            }
                          }
                        }catch (e) {
                          if(mounted) {
                            showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}');
                          }
                        }
                      }
                    },
                  )
              ),
              SizedBox(height: 20),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, '/sign_up');
                    },
                    child: Text(
                      'Don\'t have an account? Sign up now!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
              ),
            ],
          )),
    );
  }


  void showAlertDialog(BuildContext context, String message, [String title = '']) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: title == '' ? Text('Validation Error') : Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the alert dialog
            },
          ),
        ],
      ),
    );
  }

}

