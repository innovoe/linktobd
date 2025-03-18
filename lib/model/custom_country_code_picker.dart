import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CustomCountryCodePicker extends StatelessWidget {
  final ValueChanged<CountryCode> onChanged;
  final String initialSelection;
  final List<String> favorite;
  final List<String> countryFilter;
  final bool showFlagDialog;
  final BoxDecoration flagDecoration;
  final bool hideMainText;
  final bool showFlagMain;
  final bool hideSearch;
  final bool showCountryOnly;
  final bool showOnlyCountryWhenClosed;
  final bool alignLeft;
  final bool enabled;

  const CustomCountryCodePicker({
    Key? key,
    required this.onChanged,
    this.initialSelection = 'IT',
    this.favorite = const ['+39', 'FR'],
    this.countryFilter = const ['IT', 'FR'],
    this.showFlagDialog = true,
    this.flagDecoration= const BoxDecoration(),
    this.hideMainText = false,
    this.showFlagMain = false,
    this.hideSearch = false,
    this.showCountryOnly = false,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      onChanged: onChanged,
      initialSelection: initialSelection,
      favorite: favorite,
      countryFilter: countryFilter,
      showFlagDialog: showFlagDialog,
      flagDecoration: flagDecoration,
      hideMainText: hideMainText,
      showFlagMain: showFlagMain,
      hideSearch: hideSearch,
      showCountryOnly: showCountryOnly,
      showOnlyCountryWhenClosed: showOnlyCountryWhenClosed,
      alignLeft: alignLeft,
      enabled: enabled,
    );
  }
}
