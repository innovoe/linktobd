import 'package:dio/dio.dart';
import 'package:link2bd/model/memory.dart';

class PeopleModel{

  Future<dynamic> getPeopleList() async{
    FormData formData = FormData.fromMap({
      'token' : memory.token,
      'platform_id' : memory.platformId.toString()
    });
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/browse_people',
      data: formData,
    );
    return responses.data;
    var people = [];
    for(var response in responses.data){
      var person = {
        'photo': response['photo'].toString(),
        'name': response['name'].toString(),
        'nickname': response['nickname'].toString(),
        'email': response['email'].toString(),
        'occupation': response['occupation'],
        'city': response['city'].toString(),
      };
      people.add(person);
    }
    return people;
  }

}