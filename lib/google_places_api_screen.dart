import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/map_key.dart';

class GooglePlacesApiScreen extends StatefulWidget {
  const GooglePlacesApiScreen({super.key});

  @override
  State<GooglePlacesApiScreen> createState() => _GooglePlacesApiScreenState();
}

class _GooglePlacesApiScreenState extends State<GooglePlacesApiScreen> {
  TextEditingController _controller = TextEditingController();

  var uuid = Uuid();

  String sessionToken = "1234556";

  List<dynamic> _placesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (sessionToken == null) {
      setState(() {
        sessionToken = uuid.v4();
      });
    }
    if (_controller.text.length > 0) {
      getSuggestions(_controller.text);
      setState(() {
        hideSuggestion = true;
      });
    } else {
      setState(() {
        hideSuggestion = false;
        _placesList = [];
      });
    }
  }

  void getSuggestions(String input) async {
    // String kPLACES_API_KEY = "AIzaSyAAlmEtjJOpSaJ7YVkMKwdSuMTbTx39l_o";
    String kPLACES_API_KEY = mapKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    // print(data);
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  var hideSuggestion = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Google Search Places Api"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(hintText: "Search places with name"),
            ),
            Visibility(
              visible: hideSuggestion,
              child: Expanded(
                  child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            List<Location> locations =
                                await locationFromAddress(
                                    _placesList[index]['description']);
                            print(locations.last.latitude);
                            print(locations.last.longitude);
                            setState(() {
                              _controller.text =
                                  _placesList[index]['description'];
                              _placesList = [];
                              hideSuggestion = false;
                            });
                          },
                          title: Text(_placesList[index]['description']),
                        );
                      })),
            )
          ],
        ),
      ),
    );
  }

}
