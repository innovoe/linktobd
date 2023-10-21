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
      memory.userId = int.parse(data);
      return int.parse(data);
    }else{ //file doesn't exist
      idFile.create(recursive: true);
      idFile.writeAsString('0');
      memory.userId = 0;
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
        memory.userId = int.parse(webResponse.body);
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
    idFile.writeAsString(memory.userId.toString());
  }

}