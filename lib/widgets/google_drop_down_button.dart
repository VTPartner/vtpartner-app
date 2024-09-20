import 'package:flutter/material.dart';
import 'package:vt_partner/utils/app_styles.dart';

class GoogleDropdownButton extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? selectedValue;
  final String hintText;
  final ValueChanged<String?>? onChanged;

  const GoogleDropdownButton({
    Key? key,
    required this.labelText,
    required this.items,
    this.selectedValue,
    this.onChanged, required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 0.1, // Adjust the border width here
            ),
          ),
          labelText: labelText,
          labelStyle: nunitoSansStyle.copyWith(
            color: Colors.black,
            fontSize: 14,
          ),
          hintText: hintText,
          hintStyle: nunitoSansStyle.copyWith(
            color: Colors.grey,
            fontSize: 12,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: Colors.grey, // Adjust the color if needed
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: nunitoSansStyle.copyWith(
                fontSize: 14.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
