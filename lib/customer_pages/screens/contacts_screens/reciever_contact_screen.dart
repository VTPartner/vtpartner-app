import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:vt_partner/assistants/assistant_methods.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';

class ReceiverContactScreen extends StatefulWidget {
  const ReceiverContactScreen({super.key});

  @override
  State<ReceiverContactScreen> createState() => _ReceiverContactScreenState();
}

class _ReceiverContactScreenState extends State<ReceiverContactScreen> {
  TextEditingController _controller = TextEditingController();
  bool _permissionDenied = false;
  List<Contact>? _contacts; // List of contacts
  List<Contact>? _filteredContacts; // List to store filtered contacts
  String _searchTerm = ''; // Holds the search term

  @override
  void initState() {
    super.initState();
    _loadContacts();
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
                            leading: Icon(
                              Icons.phone_in_talk_rounded,
                              color: ThemeClass.facebookBlue,
                            ),
                            onTap: () async {
                              //saving Sender Contact Details to Provider
                              AssistantMethods.saveReceiverContactDetails(
                                  fullContact.displayName,
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
}
