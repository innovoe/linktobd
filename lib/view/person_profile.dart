import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/custom_page_route_animator.dart';
import 'package:linktobd/view/private_chat2.dart';

class PersonDetails extends StatefulWidget {
  final Map<String, dynamic> personJson;
  PersonDetails({super.key, required this.personJson});

  @override
  State<PersonDetails> createState() => _PersonDetailsState();
}

class _PersonDetailsState extends State<PersonDetails> {
  @override
  Widget build(BuildContext context) {
    // Early return if there is no data
    if (widget.personJson.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Extracting user data
    final imageUrl = widget.personJson['photo'];
    final name = widget.personJson['name'] ?? 'Unavailable';
    final nickname = widget.personJson['nickname'] ?? 'Unavailable';
    final username = widget.personJson['username'] ?? 'Unavailable';
    final email = widget.personJson['email'] ?? 'Unavailable';
    final dob = widget.personJson['dateofbirth'] ?? 'Unavailable';
    final phone = widget.personJson['phone'] ?? 'Unavailable';
    final gender = widget.personJson['gender'] ?? 'Unavailable';
    final bio = widget.personJson['short_bio'] ?? 'Unavailable';
    final occupation = widget.personJson['occupation'] ?? 'Unavailable';
    final education = widget.personJson['education'] ?? 'Unavailable';
    final religion = widget.personJson['religion'] ?? 'Unavailable';
    final city = widget.personJson['city'] ?? 'Unavailable';
    final state = widget.personJson['state'] ?? 'Unavailable';
    final zipCode = widget.personJson['zip_code'] ?? 'Unavailable';
    final country = widget.personJson['country'] ?? 'Unavailable';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // TODO: Implement sending private message
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Circular Image section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 100, // Adjust the size as needed
                backgroundImage: CachedNetworkImageProvider('https://linktobd.com/assets/user_dp/$imageUrl'),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image load error
                },
              ),
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: $name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5), // Adjust the height for desired spacing
                  Text("Nickname: $nickname"),
                  SizedBox(height: 5), // Repeat the SizedBox between each Text widget for spacing
                  Text("Email: $email"),
                  SizedBox(height: 5),
                  Text("Date of Birth: $dob"),
                  SizedBox(height: 5),
                  Text("Phone: $phone"),
                  SizedBox(height: 5),
                  Text("Gender: $gender"),
                  SizedBox(height: 5),
                  Text("Bio: $bio"),
                  SizedBox(height: 5),
                  Text("Occupation: $occupation"),
                  SizedBox(height: 5),
                  Text("Education: $education"),
                  SizedBox(height: 5),
                  Text("Religion: $religion"),
                  SizedBox(height: 5),
                  Text("City: $city"),
                  SizedBox(height: 5),
                  Text("State: $state"),
                  SizedBox(height: 5),
                  Text("ZIP Code: $zipCode"),
                  SizedBox(height: 5),
                  Text("Country: $country"),
                  SizedBox(height: 12),  // Spacing before the button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          CustomPageRouteAnimator(child: PrivateChat(chatPartnerName: name, username: username, chatPartnerImage: 'https://linktobd.com/assets/user_dp/$imageUrl'), direction: 'fromRight')
                      );
                    },
                    child: Text('Send Private Message'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
