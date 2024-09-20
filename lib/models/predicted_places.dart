class PredictedPlaces {
  String? place_id;
  String? main_text;
  String? description;

  PredictedPlaces({
    this.place_id,
    this.main_text,
    this.description
  });

  PredictedPlaces.fromJson(Map<String,dynamic> jsonData)
  {
    place_id = jsonData["place_id"];
    main_text = jsonData["main_text"];
    description = jsonData["description"];
  }
}