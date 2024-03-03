import 'package:frontend/models/base/base_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre extends BaseEntity {
  String name;

  Genre({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  // A necessary instance method for converting a Genre instance to a map.
  // Pass the map to the generated `_$GenreToJson()` method.
  // The method is named after the source class, in this case, Genre.
  Map<String, dynamic> toJson() => _$GenreToJson(this);

  // static fromJson(track) {
  //   return Genre(
  //     name: track['name'] ?? '',
  //   );
  // }
}
