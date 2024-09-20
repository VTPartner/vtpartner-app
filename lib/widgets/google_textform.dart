import 'package:flutter/material.dart';
import 'package:vt_partner/utils/app_styles.dart';

class GoogleTextFormField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String hintText;

  final TextInputType textInputType;

  final TextCapitalization? textCapitalization;

  final bool? readOnly;

  final String labelText;

  const GoogleTextFormField({
    Key? key,
    this.textEditingController,
    this.readOnly,
    this.textCapitalization,
    required this.hintText,
    required this.textInputType,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: TextField(
        readOnly: readOnly ?? false,
        textInputAction: TextInputAction.done,
        style: nunitoSansStyle.copyWith(
                  fontSize: 12.0, // Adjust the font size as needed
                  color: Colors.grey[
                      900], // You can also change the text color if necessary
                ),
        controller: textEditingController,
        keyboardType: textInputType,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
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
        ),
      ),
    );
  }
}
