class ArtistQuery {
  final String? name;

  ArtistQuery({this.name});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (name != null) params.add('?name=$name');
    return params;
  }
}
