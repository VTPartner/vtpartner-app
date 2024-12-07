class AllGuideLinesModal {
  final int guideLineId;
  final String guideLineDsc;

  AllGuideLinesModal({
    required this.guideLineId,
    required this.guideLineDsc,
  });

  // Factory method to create a Service object from a map (e.g., from JSON response)
  factory AllGuideLinesModal.fromJson(Map<String, dynamic> json) {
    return AllGuideLinesModal(
      guideLineId: json['guide_id'],
      guideLineDsc: json['guide_line'],
    );
  }

  // Method to convert Service object to JSON (for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'guide_id': guideLineId,
      'guide_line': guideLineDsc,
    };
  }
}
