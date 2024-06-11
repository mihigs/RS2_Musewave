class TrackQuery {
  final String? name;
  final int? artistId;
  final int? trackId;

  TrackQuery({this.name, this.artistId, this.trackId});

  List<String> toQueryParameters() {
    List<String> params = [];
    if (name != null) params.add('?name=$name');
    if (artistId != null) params.add('?artistId=$artistId');
    if (trackId != null) params.add('?trackId=$trackId');
    return params;
  }
}
