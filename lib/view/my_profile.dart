import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/custom_page_route_animator.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linktobd/model/dynamic_dropdown.dart';
import 'package:linktobd/model/widgets.dart';
import 'package:linktobd/view/photo_upload.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  UserModel userModel = UserModel();
  var uData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BadgeAppBar(title: 'My Profile'),
      drawer: AppDrawer(currentRouteName: '/my_profile'),
      body: userProfileData(context),
    );
  }

  Widget userProfileData(BuildContext context) {
    return FutureBuilder(
      future: userModel.userProfileInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available.'));
        } else {
          uData = snapshot.data!;
          String userPhoto = uData['photo'] == '' || uData['photo'] == null ? 'default_dp.jpg' : uData['photo'];
          print(uData['photo']);
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 75,
                          backgroundImage: NetworkImage('https://linktobd.com/assets/user_dp/$userPhoto'),
                          backgroundColor: Colors.transparent,
                        ),
                        onLongPress: (){
                          Navigator.of(context).push(
                              CustomPageRouteAnimator(child: PhotoUpload(setProfileState: setTheState), direction: 'fromBottom')
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(uData['name'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(uData['short_bio'] ?? '', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _profileDetails.length,
                    itemBuilder: (context, index) {
                      var detail = _profileDetails[index];
                      String key = detail['key'];
                      bool locked = uData['_$key'] == null ? detail['locked'] : (int.parse(uData['_$key']) == 0 ? false : true);
                      return detailCard(detail['title'], uData[detail['key']] ?? 'Not available', detail['icon'], detail['type'], detail['key'], detail['table'], locked);
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        }
      },
    );
  }

  setTheState(){
    setState(() {

    });
  }

  final List<Map<String, dynamic>> _profileDetails = [
    {'title': 'Name', 'table' : '', 'key': 'name', 'icon': Icons.face, 'type': 'text', 'locked': false},
    {'title': 'Email', 'table' : '', 'key': 'email', 'icon': Icons.email, 'type': 'text', 'locked': false},
    {'title': 'Phone', 'table' : '', 'key': 'phone', 'icon': Icons.phone, 'type': 'text', 'locked': false},
    {'title': 'Date of Birth', 'table' : '', 'key': 'dateofbirth', 'icon': Icons.cake, 'type': 'date', 'locked': false},
    {'title': 'Occupation', 'table' : '', 'key': 'occupation', 'icon': Icons.work, 'type': 'text', 'locked': false},
    {'title': 'Nickname', 'table' : '', 'key': 'nickname', 'icon': Icons.person, 'type': 'text', 'locked': false},
    {'title': 'Height', 'table' : 'heights', 'key': 'height_id', 'icon': Icons.accessibility, 'type': 'dropdown', 'locked': false},
    {'title': 'Gender', 'table' : 'genders', 'key': 'gender_id', 'icon': Icons.wc, 'type': 'dropdown', 'locked': false},
    {'title': 'Short Bio', 'table' : '', 'key': 'short_bio', 'icon': Icons.description, 'type': 'text', 'locked': false},
    {'title': 'Religion', 'table' : '', 'key': 'religion', 'icon': Icons.account_balance, 'type': 'text', 'locked': false},
    {'title': 'Address', 'table' : '', 'key': 'street_addr', 'icon': Icons.location_city, 'type': 'text', 'locked': false},
    {'title': 'Zip Code', 'table' : '', 'key': 'zip_code', 'icon': Icons.code, 'type': 'text', 'locked': false},
  ];

  Widget detailCard(String title, String value, IconData icon, String type, String key, String table, bool locked) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title),
        subtitle: Text(value),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //edit
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                showEditDialog(context, title, type, key, table, value);
              },
            ),
            (key == 'name' || key == 'nickname' || key == 'short_bio') ?
            //fake invisible icon
            IconButton(
              icon: locked ? Icon(Icons.visibility_off, color: Colors.grey) : Icon(Icons.public, color: Colors.grey),
              onPressed: () {
                showAlertDialog(context, '$title cannot be private.', 'Privacy');
              },
            ) :
            //private public
            IconButton(
              icon: locked ? Icon(Icons.visibility_off, color: Colors.grey) : Icon(Icons.public),
              onPressed: () async{
                Dio dio = Dio();
                final formData = FormData.fromMap({
                  'token': memory.token,
                  'field': '_$key'
                });
                try{
                  var response  = await dio.post('https://linktobd.com/appapi/change_privacy', data: formData);
                  if(response.statusCode == 200){
                    var data = response.data;
                    String message = data['message'].toString();
                    String header = data['success'].toString() == 'yes' ? 'Successful' : 'Failed';
                    showAlertDialog(context, '$message', 'Privacy: $header');
                  }
                }catch(e){
                  showAlertDialog(context, 'server error: $e', 'Oops!');
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(BuildContext context, String title, String type, String key, String table, String currentValue) {
    TextEditingController _controller = TextEditingController(text: currentValue);
    DateTime selectedDate = DateTime.now();
    File? selectedImage;
    String? selectedOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
          ),
          child: Wrap(
            children: [
              ListTile(
                title: Text('Edit $title'),
              ),
              if (type == 'text') Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter new $title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (type == 'date') Padding(
                padding: const EdgeInsets.all(8.0),
                child: DatePickerWidget(
                  looping: false,
                  firstDate: DateTime(1900, 1, 1),
                  lastDate: DateTime.now(),
                  initialDate: selectedDate,
                  dateFormat: "dd/MMMM/yyyy",
                  onChange: (DateTime newDate, _) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),
              if (type == 'dropdown') Padding(
                padding: const EdgeInsets.all(8.0),
                child: DynamicDropdown(
                  url: 'https://linktobd.com/appapi/dropdown/$table/title/',
                  onSelected: (value) {
                    setState(() {
                      selectedOption = value.toString();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('Save'),
                  onPressed: () async{
                    // Handle save logic here, e.g., update the model and refresh the UI
                    String updatedValue;
                    if (type == 'text') {
                      // uData[key] = _controller.text;
                      updatedValue = _controller.text;
                    } else if (type == 'date') {
                      // uData[key] = selectedDate.toIso8601String();
                      updatedValue = selectedDate.toIso8601String();
                    } else if (type == 'dropdown') {
                      // uData[key] = selectedOption;
                      updatedValue = selectedOption.toString();
                    } else {
                      updatedValue = '';
                    }
                    Dio dio = Dio();
                    final formData = FormData.fromMap({
                      'token': memory.token,
                      'field': key,
                      'value' : updatedValue
                    });
                    try{
                      var response = await dio.post('https://linktobd.com/appapi/user_profile_update', data: formData);
                      setState(() {});
                    }catch(e){
                      print(e.toString());
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
