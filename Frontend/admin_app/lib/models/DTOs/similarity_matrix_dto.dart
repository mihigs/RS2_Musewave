import 'package:admin_app/models/genre.dart';

class SimilarityMatrixDto {
  List<Genre> genres;
  List<List<double>> similarityScores;


  SimilarityMatrixDto({
    required this.genres,
    required this.similarityScores,
  });

  factory SimilarityMatrixDto.fromJson(Map<String, dynamic> json) => SimilarityMatrixDto(
    genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
    similarityScores: List<List<double>>.from(json["similarityScores"].map((x) => List<double>.from(x))),
  );

  Map<String, dynamic> toJson() => {
    "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
    "similarityScores": List<dynamic>.from(similarityScores.map((x) => List<dynamic>.from(x))),
  };
}
