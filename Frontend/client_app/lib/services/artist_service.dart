import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/DTOs/ArtistDetailsDto.dart';
import 'package:frontend/models/artist.dart';
import 'package:frontend/services/base/api_service.dart';

class ArtistService extends ApiService {
  final FlutterSecureStorage secureStorage;

  ArtistService(this.secureStorage) : super(secureStorage: secureStorage);

  Future<List<Artist>> getArtistsByName(String name) async {
    try {
      final response = await httpGet('Artist/GetArtistsByName?name=$name');

      List<dynamic> data = List<dynamic>.from(response['data']);

      // Convert each Map to a Artist
      final List<Artist> result = List.empty(growable: true);

      for (var item in data) {
        result.add(Artist.fromJson(item));
      }

      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<ArtistDetailsDto> getArtistDetails(int artistId, bool isJamendoArtist) async {
    try {
      final response = await httpGet('Artist/GetArtistDetails?artistId=$artistId&isJamendoArtist=$isJamendoArtist');
      return ArtistDetailsDto.fromJson(response['data']);
    } on Exception {
      rethrow;
    }
  }

}
