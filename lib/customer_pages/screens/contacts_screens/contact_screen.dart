import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsListScreen extends StatefulWidget {
  @override
  _ContactsListScreenState createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
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
          title: Text('Contacts'),
        ),
        body: _body());
  }

  Widget _body() {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (_contacts == null) return Center(child: CircularProgressIndicator());
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name or number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterContacts(value);
              },
            ),
          ),
          Expanded(
            child: _filteredContacts == null
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredContacts!.length,
                    itemBuilder: (context, i) => FutureBuilder(
                      future:
                          FlutterContacts.getContact(_filteredContacts![i].id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text(_filteredContacts![i].displayName),
                            subtitle: Text('Loading phone number...'),
                            leading: Icon(Icons.phone_in_talk_rounded),
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
                            title: Text(fullContact.displayName),
                            subtitle: Text('Phone number: $phoneNumber'),
                            leading: Icon(Icons.phone_in_talk_rounded),
                            onTap: () async {
                              // Optional: handle tap if needed
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
        ],
      );
    
  }

}
