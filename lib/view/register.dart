import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:linktobd/model/login_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CountryCode _selectedCountryCode = CountryCode.fromCountryCode('CH');
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String phoneNumberFull = '';
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  int _timer = 300;
  bool _working = false;
  late Timer _countdownTimer;
  String _phoneNumberError = '';
  String _otpError = '';

  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        timer.cancel();
        _cancelVerifyOtp();
      }
    });
  }

  bool _validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^[0-9]+$'); // Ensure the phone number contains only digits
    if (phoneNumber.isEmpty) {
      setState(() {
        _phoneNumberError = 'Phone number cannot be empty';
      });
      return false;
    } else if (!regex.hasMatch(phoneNumber)) {
      setState(() {
        _phoneNumberError = 'Phone number can only contain digits';
      });
      return false;
    } else if (phoneNumber.length < 5) { // Set your desired minimum length
      setState(() {
        _phoneNumberError = 'Phone number must be at least 5 digits long';
      });
      return false;
    }
    setState(() {
      _phoneNumberError = ''; // Clear any previous error messages
    });
    return true;
  }

  void _submitPhoneNumber() async {
    setState(() {
      _working = true;
    });
    final phoneNumber = _phoneNumberController.text;
    // print(_selectedCountryCode.dialCode);
    // print(_selectedCountryCode.code);
    // print(_selectedCountryCode.name);
    // print(_selectedCountryCode.flagUri);
    if (_selectedCountryCode != null && _validatePhoneNumber(phoneNumber)) {
      phoneNumberFull = '${_selectedCountryCode.dialCode}$phoneNumber';
      final dio = Dio();
      FormData formData = FormData.fromMap({
        'country_code': _selectedCountryCode.dialCode,
        'code': _selectedCountryCode.code,
        'name': _selectedCountryCode.name,
        'phone_number': phoneNumberFull,
        'secret_key': 'dontyoucryurikufiaddontyoucryurikufiad',
      });
      try{
        final response = await dio.post(
            'https://linktobd.com/appapi/register',
            data: formData
        );
        var out = response.data;
        print(out);
        if (out['success'] == 'exists') {
          setState(() {
            _isOtpSent = false;
            _working = false;
            _phoneNumberError = 'This phone is already registered. Try logging in.';
          });
        }else if (out['success'] == 'yes') {
          setState(() {
            _isOtpSent = true;
            _startTimer();
            _working = false;
          });
        }else{
          setState(() {
            _working = false;
          });
        }
      }catch (e){
        setState(() {
          _working = false;
          _phoneNumberError = 'Server Error: ${e.toString()}';
        });

      }

    }else{
      setState(() {
        _working = false;
      });
    }
  }



  void _verifyOtp() async{
    setState(() {
      _working = true;
    });
    final otp = _otpController.text;
    if (_validatePhoneNumber(otp)) {
      final dio = Dio();
      FormData formData = FormData.fromMap({
        'otp': otp,
        'phone_number': phoneNumberFull,
        'secret_key': 'dontyoucryurikufiaddontyoucryurikufiad',
      });
      try{
        final response = await dio.post(
            'https://linktobd.com/appapi/verify_otp',
            data: formData
        );
        var out = response.data;

        if (out['success'] == 'no') {
          setState(() {
            _isOtpVerified = false;
            _working = false;
            _otpError = 'OTP verification failed.';
          });
        }else if (out['success'] == 'yes') {
          memory.token = int.parse(out['token'].toString());
          LoginModel loginModel = LoginModel();
          await loginModel.saveId();

          UserModel userModel = UserModel();
          if(await userModel.passwordCheck()){
            Navigator.pushNamed(context, '/profile_check');
          }else{
            Navigator.pushNamed(context, '/create_password');
          }
          setState(() {
            _isOtpVerified = true;
            _working = false;
          });
        }else{
          setState(() {
            _otpError = 'Something went wrong.';
            _working = false;
          });
        }
      }catch (e){
        setState(() {
          _working = false;
          _otpError = 'Server Error: ${e.toString()}';
        });

      }

    }else{
      setState(() {
        _working = false;
      });
    }
  }

  void _cancelVerifyOtp(){
    setState(() {
      phoneNumberFull = '';
      _isOtpVerified = false;
      _isOtpSent = false;
      _timer = 300;
      _countdownTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if(_working) ...[
              Center(child: CircularProgressIndicator())
            ] else if (!_isOtpSent) ...[
              Text('Enter Your Phone Number', style: TextStyle(fontSize: 16),),
              SizedBox(height: 16,),
              (_phoneNumberError != '') ? Text(_phoneNumberError, style: TextStyle(color: Colors.red),) : Container(),
              Row(
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPhoneNumber,
                child: Text('Submit'),
              ),
            ] else if (!_isOtpVerified) ...[
              Text(phoneNumberFull, style: TextStyle(fontSize: 20),),
              Text('Please check your phone and verify the OTP'),
              SizedBox(height: 16,),
              (_otpError != '') ? Text(_otpError, style: TextStyle(color: Colors.red)) : Container(),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: Text('Verify OTP'),
              ),
              SizedBox(height: 20),
              Text(
                'Time remaining: ${_timer ~/ 60}:${(_timer % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _cancelVerifyOtp,
                child: Text('Didn\'t receive the code? Try again.'),
              ),
            ] else ...[
              Center(child: Text('OTP Verified Successfully!')),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
