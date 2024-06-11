class AlbumQuery {
  final String? title;

  AlbumQuery({this.title});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (title != null) params.add('?title=$title');
    return params;
  }
}