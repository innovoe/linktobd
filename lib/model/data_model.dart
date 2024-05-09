import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DataModel{
  Future<dynamic> getJSONData(String url, FormData formData, String saveFile) async {
    if(await checkConnectivity()){
      Dio dio = Dio();
      try {
        // Attempt to make the HTTP request
        Response response = await dio.post(url, data: formData);
        // print(response.data.toString());
        var saveData = jsonEncode(response.data);
        if (response.statusCode == 200) {
          // Success: Save the data locally and return the response
          await _saveToLocalFile(saveFile, saveData.toString()); // Note: Saving asynchronously without await

          return response.data;
        } else {
          // If the server did respond but with a non-200 status code, handle accordingly
          return await _loadFromLocalFile(saveFile);
        }
      } catch (e) {
        // This catches errors related to network issues, timeouts, etc.
        // Attempt to load from local file as a fallback
        return await _loadFromLocalFile(saveFile);
      }
    }else{
      return await _loadFromLocalFile(saveFile);
    }
  }

  Future<void> _saveToLocalFile(String fileName, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$fileName');

    // Ensure the file exists. Create it if it doesn't.
    await file.create(recursive: true);  // Creates the file and the directory path if not existent.

    // Write the data to the file, overwriting any existing content.
    await file.writeAsString(data, mode: FileMode.write);
  }


  Future<dynamic> _loadFromLocalFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$fileName');
      String contents = await file.readAsString();
      // return contents;
      // Decode the JSON string back to its original form
      return jsonDecode(contents);
    } catch (e) {
      // Handle error when unable to read the file
      print('Error decoding JSON: $e');
      // Handle or log the error as needed
      return null;
    }
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;  // No network connection
    } else {
      return await isInternetAvailable();  // Check internet availability
    }
  }

  Future<bool> isInternetAvailable() async {
    Dio dio = Dio();
    try {
      final response = await dio.get('https://linktobd.com/appapi/check_con').timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        // Consider checking response content if necessary
        return true;  // Internet is available
      } else {
        return false;  // Server responded, but not success
      }
    } catch (e) {
      return false;  // An error occurred, likely no internet
    }
  }
}