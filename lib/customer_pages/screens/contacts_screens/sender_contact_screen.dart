import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/main.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';

class SenderContactScreen extends StatefulWidget {
  const SenderContactScreen({super.key});

  @override
  State<SenderContactScreen> createState() => _SenderContactScreenState();
}

class _SenderContactScreenState extends State<SenderContactScreen> {
  TextEditingController _controller = TextEditingController();
  bool _permissionDenied = false;
  List<Contact>? _contacts; // List of contacts
  List<Contact>? _filteredContacts; // List to store filtered contacts
  String _searchTerm = ''; // Holds the search term
  String senderName = ''; // Holds the search term
  String senderNumber = ''; // Holds the search term
  String customerNumber = ''; // Holds the search term

  setSenderDetailsToMyDetails() async {
    final pref = await SharedPreferences.getInstance();
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");

    if (customer_name != null && customer_mobile_no != null) {
      AssistantMethods.saveSenderContactDetails(
          customer_name, customer_mobile_no, context);
    } else {
      MyApp.restartApp(context);
    }
  }

  getSenderDetails() async {
    final pref = await SharedPreferences.getInstance();
    var sender_name = pref.getString("sender_name");
    var sender_number = pref.getString("sender_number");
    var customer_name = pref.getString("customer_name");
    var customer_mobile_no = pref.getString("mobile_no");
    print("sender_number::$sender_number");
    print("customer_mobile_no::$customer_mobile_no");
    if (customer_mobile_no != null && customer_mobile_no!.isNotEmpty) {
      customerNumber = customer_mobile_no;
    }
    if (sender_name == null || sender_name.isEmpty) {
      senderName = customer_name.toString().split(" ")[0];
    } else {
      senderName = sender_name;
    }

    if (sender_number == null || sender_number.isEmpty) {
      senderNumber = customer_mobile_no!;
    } else {
      senderNumber = sender_number;
    }
    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    _loadContacts();
    getSenderDetails();
  }

  // Function to load contacts
  void _loadContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
      setState(() {
        _filteredContacts = _contacts; // Initially, show all contacts
      });
    }
  }

  // Function to filter contacts based on search input
  void _filterContacts(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      _filteredContacts = _contacts?.where((contact) {
        // Check if name or any phone number matches the search term
        return contact.displayName
                .toLowerCase()
                .contains(searchTerm.toLowerCase()) ||
            contact.phones.any((phone) => phone.number
                .replaceAll(' ', '')
                .contains(searchTerm.replaceAll(' ', '')));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        body: _body());
  }

  Widget _body() {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (_contacts == null) return Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextFormField(
                  onChanged: (value) {
                    _filterContacts(value);
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search',
                    border: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.clear(); // Clear the text
                              });
                            },
                          )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
            color: Colors.white,
            child: ListTile(
              title: Text(
                'Use My Number',
                style: nunitoSansStyle.copyWith(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                '${customerNumber}',
                style: nunitoSansStyle.copyWith(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
              leading: CircleAvatar(
                  backgroundColor: ThemeClass
                      .facebookBlue, // Set your desired background color
                  child: Icon(
                    Icons.person_3_outlined,
                    color: Colors.white,
                  )),
              onTap: () async {
                // Saving Sender Contact Details to Provider with the cleaned name
                // AssistantMethods.saveReceiverContactDetails(
                //   cleanedDisplayName, // Using the cleaned display name
                //   phoneNumber,
                //   context,
                // );
                setSenderDetailsToMyDetails();
                Navigator.pop(context);
              },
            )),
                                             
        const SizedBox(height: 10),
        Expanded(
          child: _filteredContacts == null
              ? Center(child: CircularProgressIndicator())
              : Container(
                  color: Colors.white,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey, // Customize the divider color
                      thickness: 0.5, // Customize the thickness
                      height: 1, // Customize the space between items
                    ),
                    itemCount: _filteredContacts!.length,
                    itemBuilder: (context, i) => FutureBuilder(
                      future:
                          FlutterContacts.getContact(_filteredContacts![i].id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text(
                              _filteredContacts![i].displayName,
                              style: nunitoSansStyle.copyWith(
                                  color: ThemeClass.backgroundColorLight),
                            ),
                            subtitle: Text('Loading phone number...'),
                            leading: Icon(
                              Icons.phone_in_talk_rounded,
                              color: ThemeClass.facebookBlue,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return ListTile(
                            title: Text(_filteredContacts![i].displayName),
                            subtitle: Text('Error loading phone number'),
                            leading: Icon(Icons.phone_in_talk_rounded),
                          );
                        }

                        if (snapshot.hasData) {
                          final fullContact = snapshot.data as Contact;
                          String phoneNumber = (fullContact.phones.isNotEmpty)
                              ? fullContact.phones.first.number
                              : 'No phone number';

                          return ListTile(
                            title: Text(
                              fullContact.displayName,
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.black, fontSize: 14.0),
                            ),
                            subtitle: Text(
                              '$phoneNumber',
                              style: nunitoSansStyle.copyWith(
                                  color: Colors.grey, fontSize: 14.0),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: ThemeClass
                                  .facebookBlue, // Set your desired background color
                              child: Text(
                                getInitials(fullContact
                                    .displayName), // Function to get initials
                                style: TextStyle(
                                  color:
                                      Colors.white, // Text color for initials
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () async {
                              //saving Sender Contact Details to Provider
                              String cleanedDisplayName =
                                  cleanDisplayName(fullContact.displayName);
                              AssistantMethods.saveSenderContactDetails(
                                  cleanedDisplayName,
                                  phoneNumber,
                                  context);
                                  Navigator.pop(context);
                            },
                          );
                        }

                        return ListTile(
                          title: Text(_filteredContacts![i].displayName),
                          subtitle: Text('Phone number: Not available'),
                          leading: Icon(Icons.phone_in_talk_rounded),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String cleanDisplayName(String displayName) {
    // Regular expression to match only alphanumeric characters and spaces
    final alphanumeric = RegExp(r'[a-zA-Z0-9\s]');

    // Replace all non-alphanumeric characters with an empty string
    return displayName.runes
        .map((int rune) => String.fromCharCode(rune))
        .where((char) => alphanumeric.hasMatch(char))
        .join()
        .trim(); // Ensure no trailing spaces are left
  }

  String getInitials(String name) {
    if (name == null || name.isEmpty) {
      return ''; // Handle empty or null name case
    }

    // Split the name by spaces and filter out empty parts
    List<String> nameParts =
        name.trim().split(' ').where((part) => part.isNotEmpty).toList();

    // Function to get the first valid alphanumeric character from each part
    String getFirstLetter(String part) {
      // Iterate over the runes (Unicode code points)
      for (var rune in part.runes) {
        String character = String.fromCharCode(rune);
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(character)) {
          return character; // Return the first alphanumeric character
        }
      }
      return ''; // Return empty string if no valid character found
    }

    // Extract the first valid letter from the first part of the name
    String firstInitial =
        nameParts.isNotEmpty ? getFirstLetter(nameParts[0]) : '';

    // Extract the first valid letter from the second part of the name (if available)
    String lastInitial =
        nameParts.length > 1 ? getFirstLetter(nameParts[1]) : '';

    // Return initials in uppercase (or a single valid letter if only one exists)
    return (firstInitial + lastInitial).toUpperCase();
  }

}
