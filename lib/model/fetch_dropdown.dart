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
