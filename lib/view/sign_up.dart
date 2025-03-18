import 'dart:io';
import 'package:linktobd/model/login_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:linktobd/model/dynamic_dropdown.dart';
import 'package:linktobd/model/photo_upload.dart';
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
  // TextEditingController cityController = TextEditingController();
  // TextEditingController stateController = TextEditingController();
  TextEditingController postalZipController = TextEditingController();
  // TextEditingController countryController = TextEditingController();
  String? countrySelected;
  String? stateSelected;
  String? citySelected;
  String? selectedGender;

  TextEditingController bioController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController religionController = TextEditingController();
  TextEditingController ethnicityController = TextEditingController();
  TextEditingController hobbiesController = TextEditingController();


  File? selectedImage;
  DateTime dateOfBirth = DateTime(2000, 1, 1);
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
            next: Text('Next'),
            done: Text('Submit'),
            showNextButton: true,
            onDone: (){
              // Navigator.pushReplacementNamed(context, '/platforms');
              // return;
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
                    File pickedFile = await photoUpload.pickImage(ImageSource.camera);
                    setState((){
                      selectedImage = File(pickedFile.path);
                    });
                  },
                ),
                OutlinedButton(
                  child: Text('Upload from gallery'),
                  onPressed: () async{
                    PhotoUpload photoUpload = PhotoUpload();
                    File pickedFile = await photoUpload.pickImage(ImageSource.gallery);
                    setState((){
                      selectedImage = File(pickedFile.path);
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
      title: "Aesthetic *",
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
              DynamicDropdown(
                url: 'https://linktobd.com/appapi/dropdown/heights/measure',
                onSelected: (value){
                  setState(() {
                    selectedHeight = value.toString();
                  });
                }
              ),
              SizedBox(height: 20,),
              Text("Gender: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10,),
              DynamicDropdown(
                  url: 'https://linktobd.com/appapi/dropdown/genders/title/',
                  onSelected: (value){
                    setState(() {
                      selectedGender = value.toString();
                    });
                  }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Text("Country: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10,),
            DynamicDropdown(
                url: 'https://linktobd.com/appapi/dropdown/countries/name/',
                onSelected: (value){
                  setState(() {
                    countrySelected = value.toString();
                    stateSelected = null; // Reset selected state
                    citySelected = null; // Reset selected city, if dependent on state
                  });
                }
            ),
            if(countrySelected != null) SizedBox(height: 20),
            if(countrySelected != null) Text("State: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if(countrySelected != null) SizedBox(height: 10,),
            if(countrySelected != null) DynamicDropdown(
                key: ValueKey(countrySelected),
                url: 'https://linktobd.com/appapi/dropdown/states/name/country_id/$countrySelected',
                onSelected: (value){
                  setState(() {
                    stateSelected = value.toString();
                    citySelected = null;
                  });
                }
            ),
            if(stateSelected != null) SizedBox(height: 20),
            if(stateSelected != null) Text("City: *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if(stateSelected != null) SizedBox(height: 10,),
            if(stateSelected != null) DynamicDropdown(
                key: ValueKey(stateSelected),
                url: 'https://linktobd.com/appapi/dropdown/cities/name/state_id/$stateSelected',
                onSelected: (value){
                  setState(() {
                    citySelected = value.toString();
                  });
                }
            ),
            SizedBox(height: 20,),
            TextField(
              controller: streetAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Street Address *',
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
    if (citySelected == null) {
      showAlertDialog(context, 'City is mandatory.');
      introKey.currentState?.controller?.animateToPage(3, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      return false;
    }

    // Validate state
    if (stateSelected == null) {
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
    if (countrySelected == null) {
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
      'name': fullNameController.text,
      'nickname': nickNameController.text,
      'email': emailController.text,
      'dateofbirth': dateOfBirth.toIso8601String(),
      'height_id': selectedHeight,
      'phone': phoneController.text,
      'gender_id': selectedGender, // Assuming gender_id is the actual gender value
      'short_bio': bioController.text,
      'occupation': occupationController.text,
      'education': educationController.text,
      'religion': religionController.text,
      'ethnicity': ethnicityController.text,
      'hobbies': hobbiesController.text,
      'street_addr': streetAddressController.text,
      'city_id': citySelected,
      'state_id': stateSelected,
      'zip_code': postalZipController.text,
      'country_id': countrySelected
    });

    var dio = Dio();
    try {
      Response response = await dio.post(
        'https://linktobd.com/appapi/sign_up',
        data: formData,
      );

      var respond = response.data;
      if (response.statusCode == 200) {
        if(mounted){
          if(respond['success'].toString() == 'yes'){
            showAlertDialog(context, 'Successfully registered!', 'Congratulations!');
            memory.token = int.parse(respond['token']);
            LoginModel loginModel = LoginModel();
            await loginModel.saveId();
            Future.delayed(const Duration(seconds: 2)).then((val) {
              Navigator.pushReplacementNamed(context, '/create_password');
            });
          }
        }
      } else {
        if(mounted) {
          showAlertDialog(context, 'Failed to register.');
        }
      }
    } catch (e) {
      if(mounted) {
        showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

}

