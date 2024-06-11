class JamendoTrackQuery {
  final String? name;

  JamendoTrackQuery({this.name});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (name != null) params.add('?name=$name');
    return params;
  }
}