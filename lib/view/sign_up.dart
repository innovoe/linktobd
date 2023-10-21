import 'dart:io';

import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:link2bd/model/photo_upload.dart';
import 'package:dio/dio.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final introKey = GlobalKey<IntroductionScreenState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController streetAddressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postalZipController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  List<String> preferenceOptions = ['Men', 'Women', 'Everyone'];

  String? selectedGender;
  String? selectedPreference;
  List<String> relationshipGoals = [
    'Friendship',
    'Casual Dating',
    'Long-term Relationship',
    'Marriage'
  ];
  String? selectedGoal;

  TextEditingController bioController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController religionController = TextEditingController();
  TextEditingController ethnicityController = TextEditingController();
  TextEditingController hobbiesController = TextEditingController();


  File? selectedImage;
  DateTime dateOfBirth = DateTime(2000, 1, 1);
  List<String> heightOptions = [
    '4\'0"', '4\'1"', '4\'2"', '4\'3"', '4\'4"', '4\'5"',
    '4\'6"', '4\'7"', '4\'8"', '4\'9"', '4\'10"', '4\'11"',
    '5\'0"', '5\'1"', '5\'2"', '5\'3"', '5\'4"', '5\'5"',
    '5\'6"', '5\'7"', '5\'8"', '5\'9"', '5\'10"', '5\'11"',
    '6\'0"', '6\'1"', '6\'2"', '6\'3"', '6\'4"', '6\'5"',
    '6\'6"', '6\'7"', '6\'8"', '6\'9"', '6\'10"', '6\'11"',
    '7\'0"'
  ];
  String? selectedHeight;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          IntroductionScreen(
            key: introKey,
            pages: [
              uploadImage(),
              birthDate(),
              basicInfo(),
              addressInfo(),
              bioInfo()
            ],
            done: Text('Submit'),
            showNextButton: false,
            onDone: (){
              Navigator.pushReplacementNamed(context, '/platforms');
              return;
              if(validate()){
                signUp(context);
              }
            },
          ),
          if(isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),  // This creates a translucent black color
                child: Center(
                  child: CircularProgressIndicator(),  // Loading indicator in the center
                ),
              ),
            ),
        ],
      ),
    );
  }

  PageViewModel uploadImage(){
    return PageViewModel(
      title: "Upload your profile picture *",
      bodyWidget: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            (selectedImage == null) ? Image.asset('assets/default_dp.jpg') : Image.file(selectedImage!),
            SizedBox(height: 30,),
            Row(
              children: [
                OutlinedButton(
                  child: Text('Take a new photo'),
                  onPressed: () async{
                    PhotoUpload photoUpload = PhotoUpload();
                    XFile? pickedFile = await photoUpload.pickImage(ImageSource.camera);
                    setState((){
                      selectedImage = File(pickedFile!.path);
                    });
                  },
                ),
                OutlinedButton(
                  child: Text('Upload from gallery'),
                  onPressed: () async{
                    PhotoUpload photoUpload = PhotoUpload();
                    XFile? pickedFile = await photoUpload.pickImage(ImageSource.gallery);
                    setState((){
                      selectedImage = File(pickedFile!.path);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  PageViewModel birthDate() {
    return PageViewModel(
      title: "Age and Height *",
      bodyWidget: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date of Birth: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10,),
              DatePickerWidget(
                looping: false,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1900, 1, 1),
                lastDate: DateTime.now(),
                dateFormat: "dd/MMMM/yyyy",
                onChange: (DateTime newDate, _) {
                  setState(() {
                    dateOfBirth = newDate;
                  });
                },
              ),
              SizedBox(height: 20,),
              Text("Height: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: selectedHeight,
                items: heightOptions.map((String height) {
                  return DropdownMenuItem<String>(
                    value: height,
                    child: Text(height),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHeight = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  PageViewModel basicInfo(){
    return PageViewModel(
      title: "Basic Information",
      bodyWidget: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Full name *',
                ),
              ),
              SizedBox(height: 30,),
              TextField(
                controller: nickNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nickname *',
                ),
              ),
              SizedBox(height: 30,),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email *',
                ),
              ),
              SizedBox(height: 30,),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone *',
                ),
              ),
              SizedBox(height: 30,),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gender *',
                ),
              ),
              SizedBox(height: 20,),
              DropdownButtonFormField<String>(
                value: selectedPreference,
                items: preferenceOptions.map((String preference) {
                  return DropdownMenuItem<String>(
                    value: preference,
                    child: Text(preference),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPreference = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Gender Preference',
                ),
              ),
              SizedBox(height: 20,),
              DropdownButtonFormField<String>(
                value: selectedGoal,
                items: relationshipGoals.map((String goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGoal = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Relationship Goal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  PageViewModel addressInfo() {

    return PageViewModel(
      title: "Address Information *",
      bodyWidget: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            TextField(
              controller: streetAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Street Address *',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'City *',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: stateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'State/Province *',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: postalZipController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Postal/ZIP Code *',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Country *',
              ),
            ),
          ],
        ),
      ),
    );
  }




  PageViewModel bioInfo() {

    return PageViewModel(
      title: "Bio & Background",
      bodyWidget: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            TextField(
              controller: bioController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Short Bio or About Me',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: occupationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Occupation',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: educationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Educational Background',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: religionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Religious Belief',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: ethnicityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ethnicity or Background',
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: hobbiesController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Hobbies & Interests',
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }









  bool validate() {
    // Validate photo
    if (selectedImage == null) {
      showAlertDialog(context, 'Please upload a photo.');
      introKey.currentState?.controller?.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate birth date
    if (dateOfBirth == DateTime.now()) {
      showAlertDialog(context, 'Please select your birth date.');
      introKey.currentState?.controller?.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate height
    if (selectedHeight == null || selectedHeight!.isEmpty) {
      showAlertDialog(context, 'Please select your height.');
      introKey.currentState?.controller?.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate full name
    if (!isValidName(fullNameController.text)) {
      showAlertDialog(context, 'Full name is mandatory.');
      introKey.currentState?.controller?.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate nickname
    if (!isValidName(nickNameController.text)) {
      showAlertDialog(context, 'Nickname is mandatory.');
      introKey.currentState?.controller?.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate email
    if (!isValidEmail(emailController.text)) {
      showAlertDialog(context, 'Valid email is mandatory.');
      introKey.currentState?.controller?.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate phone
    if (phoneController.text.isEmpty) {
      showAlertDialog(context, 'Phone number is mandatory.');
      introKey.currentState?.controller?.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate gender
    if (selectedGender == null || selectedGender!.isEmpty) {
      showAlertDialog(context, 'Please select a gender.');
      introKey.currentState?.controller?.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate street address
    if (streetAddressController.text.isEmpty) {
      showAlertDialog(context, 'Street Address is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate city
    if (cityController.text.isEmpty) {
      showAlertDialog(context, 'City is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate state
    if (stateController.text.isEmpty) {
      showAlertDialog(context, 'State is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate postal/zip code
    if (postalZipController.text.isEmpty) {
      showAlertDialog(context, 'Postal/Zip code is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate country
    if (countryController.text.isEmpty) {
      showAlertDialog(context, 'Country is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }


    return true; // if all validations pass
  }

  bool isValidName(String name) => name.isNotEmpty;

  bool isValidEmail(String email) => email.isNotEmpty && email.contains('@');

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
















  void signUp(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    // Construct the data
    FormData formData = FormData.fromMap({
      'photo': selectedImage != null ? await MultipartFile.fromFile(selectedImage!.path) : null,
      'fullname': fullNameController.text,
      'nickname': nickNameController.text,
      'email': emailController.text,
      'dateofbirth': dateOfBirth.toIso8601String(),
      'height': selectedHeight,
      'phone': phoneController.text,
      'gender_id': selectedGender, // Assuming gender_id is the actual gender value
      'gender_pref_id': selectedPreference, // Adjust if needed
      'rel_goal_id': selectedGoal, // Adjust if needed
      'short_bio': bioController.text,
      'occupation': occupationController.text,
      'education': educationController.text,
      'religion_id': religionController.text, // Adjust if this is an ID
      'street_addr': streetAddressController.text,
      'city': cityController.text,
      'state': stateController.text,
      'zip_code': postalZipController.text,
      'country_id': countryController.text, // Adjust if this is an ID
    });

    var dio = Dio();
    try {
      Response response = await dio.post(
        'https://linktobd.com/appapi/user_sign_up',
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200) {
        if(mounted){
          showAlertDialog(context, 'Successfully registered!', 'Congratulations!');
          // Navigator.pushReplacementNamed(context, '/platforms');
        }
      } else {
        if(mounted) {
          showAlertDialog(context, 'Failed to register.');
        }
      }
    } catch (e) {
      print(e);
      if(mounted) {
        showAlertDialog(context, 'An error occurred. Please try again.');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

}

