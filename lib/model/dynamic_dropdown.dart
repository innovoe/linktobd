import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DynamicDropdown extends StatefulWidget {
  final String url;
  final Function(String) onSelected;

  // DynamicDropdown({required this.url, required this.onSelected});
  DynamicDropdown({Key? key, required this.url, required this.onSelected})
      : super(key: key); // passing key to the super class constructor


  @override
  _DynamicDropdownState createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  String? selectedValue;
  List<DropdownItem> dropdownItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownItems();
  }

  fetchDropdownItems() async {
    try {
      var response = await Dio().get(widget.url);
      List<dynamic> rawData = response.data;
      setState(() {
        dropdownItems = rawData.map((item) => DropdownItem.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : DropdownButtonFormField<String>(
      value: selectedValue,
      onChanged: (newValue) {
        setState(() {
          selectedValue = newValue;
        });
        widget.onSelected(newValue!);
      },
      items: dropdownItems.map((DropdownItem item) {
        return DropdownMenuItem<String>(
          value: item.key,
          child: Text(item.value),
        );
      }).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}



class DropdownItem {
  String key;
  String value;

  DropdownItem({required this.key, required this.value});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      key: json['key'],
      value: json['value'],
    );
  }
}
