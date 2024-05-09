import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:link2bd/model/memory.dart';
import 'package:http/http.dart' as http;

class LoginModel{

  final String key1 = 'dontyoucryurikufiaddontyoucryurikufiad';
  final String key2 = 'letsgoyeahcomeoncomeonturntheradioonitsfrydaynight';
  final String clientUrl = 'https://linktobd.com/appapi/app_login';

  //0 means new file created
  Future<int> getId() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath = '${appDir.path}/id.txt';
    File idFile = File(idFilePath);
    if(await idFile.exists()){
      String data = await idFile.readAsString();
      memory.token = int.parse(data);
      return int.parse(data);
    }else{ //file doesn't exist
      idFile.create(recursive: true);
      idFile.writeAsString('0');
      memory.token = 0;
      return 0;
    }
  }

  Future<String> appLogin(String username, String password) async {
    var client = http.Client();
    try{
      var webResponse = await client.post(
          Uri.parse(clientUrl),
          body: {
            'key1' : key1,
            'key2' : key2,
            'username' : username,
            'password' : password
          }
      );
      if(webResponse.body == 'auth_error'){
        return 'Authentication Error. Please contact System Administrator.';
      }else if(webResponse.body == '0'){
        return 'Wrong username or password';
      }else{
        memory.token = int.parse(webResponse.body);
        saveId();
        return 'Login Success';
      }
    }catch(e){
      return 'Server Error ${e.toString()}  Please contact System Administrator';
    }
  }

  Future<void> saveId() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath =  '${appDir.path}/id.txt';
    File idFile = File(idFilePath);
    idFile.writeAsString(memory.token.toString());
  }

  Future<bool> logout() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory(); // Gets the application documents directory
      List<FileSystemEntity> files = appDir.listSync(); // Lists all files and directories within

      // Loop through all files and delete them
      for (FileSystemEntity file in files) {
        if (file is File) { // Checks if the entity is a file
          await file.delete(); // Deletes each file
        }
      }
      memory.token = -9;
      memory.platformId = 0;
      memory.platformName = '';
      memory.username = '';
      memory.postId = '';
      memory.postUuid = '';
      memory.commentId = '';
      memory.photoURL = '';
      memory.notificationNr = 0;
      memory.newNotifications = 0;

      return true;
    } catch (e) {
      print('Logout error: ${e.toString()}');
      return false;
    }
  }

  // Future<bool> logout() async {
  //   try {
  //     Directory appDir = await getApplicationDocumentsDirectory();
  //     String idFilePath = '${appDir.path}/id.txt';
  //     File idFile = File(idFilePath);
  //     if (await idFile.exists()) {
  //       await idFile.delete(); // Deletes the file where the token is stored.
  //       memory.token = 0; // Resets the token in memory to 0 or any default unauthenticated value.
  //       return true;
  //     } else {
  //       // The file doesn't exist, maybe the user was not logged in
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Logout error: ${e.toString()}');
  //     return false;
  //   }
  // }

}