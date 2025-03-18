import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/custom_page_route_animator.dart';
import 'package:linktobd/model/gesture_detector_drag.dart';
import 'package:linktobd/view/private_chat2.dart';

class UserProfile extends StatefulWidget {
  final String nickname;

  UserProfile({super.key, required this.nickname});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<Map<String, dynamic>> userProfile;

  @override
  void initState() {
    super.initState();
    userProfile = fetchUserProfile();
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    Dio dio = Dio();
    String url = 'https://linktobd.com/appapi/public_user_profile/${widget.nickname}';
    try {
      final response = await dio.get(url);
      return response.data;
    } catch (e) {
      print(e);
      throw 'Failed to load user profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return _buildProfileView(context, data);
          }
          return Center(child: Text('No Data'));
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Map<String, dynamic> data) {
    final imageUrl = data['photo'];
    final name = data['name'] ?? 'Unavailable';
    final nickname = data['nickname'] ?? 'Unavailable';
    final email = data['email'] ?? 'Unavailable';
    final dob = data['dateofbirth'] ?? 'Unavailable';
    final phone = data['phone'] ?? 'Unavailable';
    final gender = data['gender'] ?? 'Unavailable';
    final bio = data['short_bio'] ?? 'Unavailable';
    final occupation = data['occupation'] ?? 'Unavailable';
    final education = data['education'] ?? 'Unavailable';
    final religion = data['religion'] ?? 'Unavailable';
    final city = data['city'] ?? 'Unavailable';
    final state = data['state'] ?? 'Unavailable';
    final zipCode = data['zip_code'] ?? 'Unavailable';
    final country = data['country'] ?? 'Unavailable';

    return GestureDetectorDrag(
      swipeTo: SwipeDirection.left,
      onSwipeComplete: () => Navigator.pop(context),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Full-width profile image
            CachedNetworkImage(
              imageUrl: 'https://linktobd.com/assets/user_dp/$imageUrl',
              width: double.infinity, // Make the image take up full width
              fit: BoxFit.cover, // Cover the entire width without distortion
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          CustomPageRouteAnimator(child: PrivateChat(chatPartnerName: name, username: nickname, chatPartnerImage: 'https://linktobd.com/assets/user_dp/$imageUrl'), direction: 'fromRight')
                      );
                    },
                    child: Text('Send Private Message'),
                  ),
                  // ElevatedButton(
                  //     onPressed: (){
                  //       Navigator.pop(context);
                  //     },
                  //     child: Text('close')
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildProfileDetails(
                context,
                name,
                nickname,
                email,
                dob,
                phone,
                gender,
                bio,
                occupation,
                education,
                religion,
                city,
                state,
                zipCode,
                country,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(
      BuildContext context,
      String name,
      String nickname,
      String email,
      String dob,
      String phone,
      String gender,
      String bio,
      String occupation,
      String education,
      String religion,
      String city,
      String state,
      String zipCode,
      String country,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        _buildCardDetails(context, Icons.person, 'Nickname', nickname),
        _buildCardDetails(context, Icons.cake, 'Date of Birth', dob),
        _buildCardDetails(context, Icons.phone, 'Phone', phone),
        _buildCardDetails(context, Icons.transgender, 'Gender', gender),
        _buildCardDetails(context, Icons.info, 'Bio', bio),
        SizedBox(height: 16),
        _buildSectionHeader('Contact Information'),
        _buildCardDetails(context, Icons.email, 'Email', email),
        _buildCardDetails(context, Icons.location_city, 'City', city),
        _buildCardDetails(context, Icons.public, 'Country', country),
        _buildCardDetails(context, Icons.home, 'State', state),
        _buildCardDetails(context, Icons.code, 'ZIP Code', zipCode),
        SizedBox(height: 16),
        _buildSectionHeader('Education and Occupation'),
        _buildCardDetails(context, Icons.work, 'Occupation', occupation),
        _buildCardDetails(context, Icons.school, 'Education', education),
        _buildCardDetails(context, Icons.brightness_auto, 'Religion', religion),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCardDetails(BuildContext context, IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
