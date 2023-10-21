import 'package:link2bd/model/login_model.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 60),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Image.asset('assets/logo.png', width: 150),
              ),
              SizedBox(height: 10),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    output,
                    style: TextStyle(fontSize: 16),
                  )
              ),
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  )
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: Text('Login'),
                    onPressed: () async {
                      if(nameController.text.isEmpty || passwordController.text.isEmpty){
                        setState(() {
                          output = 'Please fill up both the phone and password field to log in.';
                        });
                      }else{
                        LoginModel loginModel = LoginModel();
                        String loginReturn = await loginModel.appLogin(nameController.text, passwordController.text);
                        setState(() {
                          output = loginReturn;
                        });
                        if(loginReturn == 'Login Success'){
                          Navigator.pushReplacementNamed(context, '/home');
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

}

