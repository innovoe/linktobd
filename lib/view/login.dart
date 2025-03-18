import 'package:country_code_picker/country_code_picker.dart';
import 'package:linktobd/model/login_model.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Widget output = Text('');

  CountryCode _selectedCountryCode = CountryCode.fromCountryCode('CH');
  TextEditingController _phoneNumberController = TextEditingController();

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
                  child: output
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
                child: Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (countryCode) {
                        setState(() {
                          _selectedCountryCode = countryCode;
                        });
                      },
                      initialSelection: _selectedCountryCode.toString(),
                      favorite: ['+41', 'CH'],
                      dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
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
                      final phoneNumber = _phoneNumberController.text;
                      String phoneNumberFull = '${_selectedCountryCode.dialCode}$phoneNumber';
                      print(phoneNumberFull);
                      setState(() {
                        output = CircularProgressIndicator();
                      });
                      if(_phoneNumberController.text.isEmpty || passwordController.text.isEmpty){
                        setState(() {
                          output = Text('Please fill up both the phone and password field to log in.', style: TextStyle(color: Colors.red),);
                        });
                      }else{
                        LoginModel loginModel = LoginModel();
                        String loginReturn = await loginModel.appLogin(phoneNumberFull, passwordController.text);
                        setState(() {
                          output = Text(loginReturn);
                        });
                        if(loginReturn == 'Login Success'){
                          setState(() {
                            output = Text(loginReturn);
                          });
                          Navigator.pushReplacementNamed(context, '/my_platforms');
                        }else{
                          setState(() {
                            output = Text('phonenumber or password didn\'t match', style: TextStyle(color: Colors.red),);
                          });
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

