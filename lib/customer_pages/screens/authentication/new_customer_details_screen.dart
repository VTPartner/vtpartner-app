import 'package:flutter/material.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';

class NewCustomerDetailsScreen extends StatefulWidget {
  const NewCustomerDetailsScreen({super.key});

  @override
  State<NewCustomerDetailsScreen> createState() =>
      _NewCustomerDetailsScreenState();
}

class _NewCustomerDetailsScreenState extends State<NewCustomerDetailsScreen> {
   String? _selectedValue;
  final List<String> _dropdownItems = [
    'Business',
    'Personal',
    'Shifting House',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Colors.grey[900],
                  )),
              SizedBox(
                height: kHeight,
              ),
              Text(
                "Profile Details",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium?.fontSize),
                overflow: TextOverflow.visible,
              ),
              Text(
                "Your information is kept confidential and used solely for verification and communication purposes",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800],
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                overflow: TextOverflow.visible,
              ),
              SizedBox(
                height: kHeight + 10,
              ),
              GoogleTextFormField(
                  hintText: 'Enter Your First Name',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'First Name *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  hintText: 'Family Name (in some contexts)',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Last Name'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  hintText: 'Enter valid Email ID',
                  textInputType: TextInputType.emailAddress,
                  labelText: 'Email ID'),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButton(
                hintText: 'Choose one option',
          labelText: 'Using VTPartner For :',
          items: _dropdownItems,
          selectedValue: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
        ),
        SizedBox(
                height: kHeight + 100,
              ),
            ],
          ),
        ),
      )),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, CustomerMainScreenRoute);
                },
                child: Ink(
                  decoration: BoxDecoration(
                      color: ThemeClass.facebookBlue,
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Register',
                              style: nunitoSansStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
