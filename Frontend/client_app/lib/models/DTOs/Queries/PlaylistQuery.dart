class PlaylistQuery {
  final String? name;
  final bool? arePublic;

  PlaylistQuery({this.name, this.arePublic});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (name != null) params.add('?name=$name');
    if (arePublic != null) params.add('?arePublic=$arePublic');
    return params;
  }
}
