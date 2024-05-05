using Azure;
using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Models.DTOs;
using Models.Entities;
using Models.Enums;
using Services.Interfaces;
using System.Text.Json;
using static Models.DTOs.JamendoApiDto;

namespace Services.Implementations
{
    public class JamendoService : IJamendoService
    {
        private readonly IConfiguration _configuration;
        private readonly ITrackRepository _trackRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IGenreRepository _genreRepository;
        private readonly ILikeRepository _likeRepository;
        private readonly IJamendoApiActivityRepository _jamendoApiActivityRepository;

        public JamendoService(IConfiguration configuration, ITrackRepository trackRepository, IArtistRepository artistRepository, IGenreRepository genreRepository, ILikeRepository likeRepository, IJamendoApiActivityRepository jamendoApiActivityRepository)
        {
            _configuration = configuration;
            _trackRepository = trackRepository;
            _artistRepository = artistRepository;
            _genreRepository = genreRepository;
            _likeRepository = likeRepository;
            _jamendoApiActivityRepository = jamendoApiActivityRepository;
        }

        public async Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName, string userId)
        {
            try
            {
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"tracks/?client_id={_configuration["Jamendo:ClientId"]}&include=musicinfo&format=jsonpretty&name={trackName}").Result;
                if (response.IsSuccessStatusCode)
                {
                    // Log the activity
                    await _jamendoApiActivityRepository.AddJamendoApiActivity(JamendoAPIActivityType.SearchJamendoByTrackName, userId);

                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiTrackResponse(serializedResponse);
                    var tracks = new List<Track>();
                    foreach (var track in deserializedResponse.Results)
                    {
                        if (track != null)
                        {
                            tracks.Add(await MapJamendoResponseToTrack(track, userId));
                        }
                    }

                    return tracks;
                }
                else
                {
                    throw new Exception("Failed to query Jamendo");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to search Jamendo by track name", e);
            }
        }

        public async Task<Track?> MapJamendoResponseToTrack(JamendoTrackResult? response, string? userId = null, int? artistId = null)
        {
            if (response != null)
            {
                // Check if track already exists in the database
                var existingTrack = await _trackRepository.GetByJamendoId(response.Id);
                if (existingTrack != null)
                {
                    // Check if the track is liked by the user
                    if (userId != null)
                    {
                        existingTrack.IsLiked = await CheckIfTrackIsLikedByUser(existingTrack.Id, userId) != null;
                    }
                    // Update the url if it has changed
                    if(response.Audio != null && response.Audio != "")
                    {
                        if(existingTrack.SignedUrl == null || existingTrack.SignedUrl != "")
                        {
                            existingTrack.SignedUrl = response.Audio;
                            await _trackRepository.Update(existingTrack);
                        }
                    }
                    return existingTrack;
                }
                var track = new Track
                {
                    JamendoId = response.Id,
                    Title = response.Name,
                    Duration = ConvertDurationToInt(response.Duration),
                    ImageUrl = response.Image,
                    SignedUrl = response.Audio,
                };

                if (artistId != null)
                {
                    track.ArtistId = artistId.Value;
                }
                else if (response.ArtistId != null)
                {
                    // Check if artist already exists in the database
                    var existingArtist = await _artistRepository.GetArtistsByNameAsync(response.ArtistName);
                    if (existingArtist.Count() > 0)
                    {
                        track.ArtistId = existingArtist.First().Id;
                    }
                    else
                    {
                        track.Artist = new Artist
                        {
                            JamendoArtistId = response.ArtistId,
                            ArtistImageUrl = response.Image,
                            User = new User
                            {
                                UserName = response.ArtistName,
                                NormalizedUserName = response.ArtistName.ToUpper(),
                                EmailConfirmed = false,
                                PhoneNumberConfirmed = false,
                                TwoFactorEnabled = false,
                                LockoutEnabled = false,
                                AccessFailedCount = 0
                            }
                        };
                    };
                }
                if (response?.MusicInfo?.Tags?.Genres != null)
                {
                    foreach (var genre in response.MusicInfo.Tags.Genres)
                    {
                        var existingGenre = await _genreRepository.GetGenresByNameAsync(genre);
                        TrackGenre trackGenre;
                        if (existingGenre.IsNullOrEmpty())
                        {
                            trackGenre = new TrackGenre
                            {
                                Genre = new Genre
                                {
                                    Name = genre
                                }
                            };
                        }
                        else
                        {
                            // Check if the track already has this genre to avoid adding a duplicate
                            var genreId = existingGenre.First().Id;
                            if (track.TrackGenres.Any(tg => tg.GenreId == genreId))
                            {
                                continue; // Skip adding this genre since it's already added
                            }

                            trackGenre = new TrackGenre
                            {
                                GenreId = genreId
                            };
                        }

                        track.TrackGenres.Add(trackGenre);
                    }
                }

                await _trackRepository.Add(track);

                return track;
            }
            return null;
        }

        static int ConvertDurationToInt(dynamic duration)
        {
            if (duration is JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Number)
                {
                    return element.GetInt32(); // Directly retrieve the integer value.
                }
                else if (element.ValueKind == JsonValueKind.String)
                {
                    // Attempt to parse the string to an integer.
                    if (int.TryParse(element.GetString(), out int parsedDuration))
                    {
                        return parsedDuration; // Successfully parsed string to int.
                    }
                }
            }
            return 0; // Default to 0 if not a JsonElement, or if parsing fails.
        }


        public JamendoApiResponse<JamendoTrackResult> MapJamendoApiTrackResponse(string response)
        {
            // Deserialize the response into JamendoApiResponse object
            var jamendoApiResponse = JsonSerializer.Deserialize<JamendoApiResponse<JamendoTrackResult>>(response);

            // Check if the deserialization was successful
            if (jamendoApiResponse is null || jamendoApiResponse.Results is null)
            {
                throw new JsonException("Failed to deserialize Jamendo API response.");
            }

            return jamendoApiResponse;
        }

        public JamendoApiResponse<JamendoArtistDetailsResult> MapJamendoApiArtistResponse(string response)
        {
            // Deserialize the response into JamendoApiResponse object
            var jamendoApiResponse = JsonSerializer.Deserialize<JamendoApiResponse<JamendoArtistDetailsResult>>(response);

            // Check if the deserialization was successful
            if (jamendoApiResponse is null || jamendoApiResponse.Results is null)
            {
                throw new JsonException("Failed to deserialize Jamendo API response.");
            }

            return jamendoApiResponse;
        }


        public async Task<IEnumerable<Track>> CheckIfTracksAreCached(IEnumerable<Track> tracks)
        {
            var newTracks = new List<Track>();
            foreach (var track in tracks)
            {
                var existingTrack = await _trackRepository.GetByJamendoId(track.JamendoId);
                if (existingTrack is null)
                {
                    newTracks.Add(track);
                }
                else
                {
                    foreach (var genre in existingTrack.TrackGenres)
                    {
                        var existingGenre = _genreRepository.GetGenresByNameAsync(genre.Genre.Name).Result.FirstOrDefault();
                        if (existingGenre is null)
                        {
                            await _genreRepository.Add(genre.Genre);
                        }
                    }
                    if (existingTrack.Artist != null)
                    {
                        var existingArtist = await _artistRepository.GetArtistsByNameAsync(track.Artist.User.UserName);
                        if (existingArtist is null)
                        {
                            await _artistRepository.Add(track.Artist);
                        }
                    }
                }
            }
            return newTracks;
        }

        public async Task<Track> GetTrackById(int trackId, string userId)
        {
            try
            {
                var track = await _trackRepository.GetByJamendoId(trackId.ToString());

                if (track is null)
                {
                    using var client = new HttpClient();
                    client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                    var response = client.GetAsync($"tracks/?client_id={_configuration["Jamendo:ClientId"]}&include=musicinfo&format=jsonpretty&id={trackId}").Result;
                    if (response.IsSuccessStatusCode)
                    {
                        // Log the activity
                        await _jamendoApiActivityRepository.AddJamendoApiActivity(JamendoAPIActivityType.GetTrackById, userId);

                        var serializedResponse = response.Content.ReadAsStringAsync().Result;
                        var result = MapJamendoApiTrackResponse(serializedResponse);
                        track = await MapJamendoResponseToTrack(result.Results.FirstOrDefault(), userId);
                    }
                    else
                    {
                        throw new Exception("Failed to get Jamendo track by id");
                    }
                }
                return track;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Error getting Jamendo track", e);
            }
        }
        public async Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId)
        {
            return await _likeRepository.CheckIfTrackIsLikedByUser(trackId, userId);
        }

        public async Task<IEnumerable<Track>> GetJamendoTracksPerGenres(string[] genres)
        {
            try
            {
                string tags = string.Join("+", genres);
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"tracks/?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&limit=5&include=musicinfo&tags={tags}").Result;
                if (response.IsSuccessStatusCode)
                {
                    // Log the activity
                    await _jamendoApiActivityRepository.AddJamendoApiActivity(JamendoAPIActivityType.GetJamendoTracksPerGenres);

                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiTrackResponse(serializedResponse);
                    var tracks = new List<Track>();
                    foreach (var track in deserializedResponse.Results)
                    {
                        if (track != null)
                        {
                            tracks.Add(await MapJamendoResponseToTrack(track));
                        }
                    }

                    return tracks;
                }
                else
                {
                    throw new Exception("Failed to query Jamendo");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to get Jamendo tracks by genres", e);
            }
        }

        public async Task<IEnumerable<Track>> GetPopularJamendoTracks()
        {
            try
            {
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"tracks/?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&limit=5&include=musicinfo&order=popularity_month").Result;
                if (response.IsSuccessStatusCode)
                {
                    // Log the activity
                    await _jamendoApiActivityRepository.AddJamendoApiActivity(JamendoAPIActivityType.GetPopularJamendoTracks);

                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiTrackResponse(serializedResponse);
                    var tracks = new List<Track>();
                    foreach (var track in deserializedResponse.Results)
                    {
                        if (track != null)
                        {
                            tracks.Add(await MapJamendoResponseToTrack(track));
                        }
                    }

                    return tracks;
                }
                else
                {
                    throw new Exception("Failed to query Jamendo");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to get popular Jamendo tracks", e);
            }
        }

        public async Task<ArtistDetailsDto> GetJamendoArtistDetails(string jamendoArtistId)
        {
            try
            {
                var result = new ArtistDetailsDto();
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"artists/tracks/?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&id={jamendoArtistId}").Result;
                if (response.IsSuccessStatusCode)
                {
                    // Log the activity
                    await _jamendoApiActivityRepository.AddJamendoApiActivity(JamendoAPIActivityType.GetJamendoArtistDetails);
                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiArtistResponse(serializedResponse);

                    // Add or update the artist
                    // Check if the artist already exists in the database
                    var existingArtist = await _artistRepository.GetArtistByJamendoId(jamendoArtistId);
                    if (existingArtist != null)
                    {
                        // Update the artist image if it has changed
                        if (existingArtist.ArtistImageUrl != deserializedResponse.Results.FirstOrDefault()?.Image)
                        {
                            existingArtist.ArtistImageUrl = deserializedResponse.Results.FirstOrDefault()?.Image;
                            await _artistRepository.Update(existingArtist);
                        }
                        result.Artist = existingArtist;
                    }
                    else
                    {
                        // Otherwise, create a new artist
                        var artist = new Artist
                        {
                            JamendoArtistId = deserializedResponse.Results.FirstOrDefault()?.Id,
                            ArtistImageUrl = deserializedResponse.Results.FirstOrDefault()?.Image,
                            User = new User
                            {
                                UserName = deserializedResponse.Results.FirstOrDefault()?.Name,
                                NormalizedUserName = deserializedResponse.Results.FirstOrDefault()?.Name.ToUpper(),
                                EmailConfirmed = false,
                                PhoneNumberConfirmed = false,
                                TwoFactorEnabled = false,
                                LockoutEnabled = false,
                                AccessFailedCount = 0
                            }
                        };
                        result.Artist = artist;
                    }

                    // Add or update tracks
                    if (deserializedResponse.Results.FirstOrDefault()?.Tracks != null)
                    {
                        var tracks = new List<Track>();
                        foreach (var track in deserializedResponse.Results.FirstOrDefault()?.Tracks)
                        {
                            if (track != null)
                            {
                                tracks.Add(await MapJamendoResponseToTrack(response: track, userId: null, artistId: result.Artist.Id));
                            }
                        }
                        result.Tracks = tracks;
                    }
                }
                else
                {
                    // Fallback, check if the artist already exists in the database
                    var existingArtist = await _artistRepository.GetArtistByJamendoId(jamendoArtistId);
                    if (existingArtist != null)
                    {
                        result.Artist = existingArtist;
                        // Get the artists tracks
                        result.Tracks = await _trackRepository.GetTracksByArtistId(existingArtist.Id);

                    }
                    else
                    {
                        throw new Exception("Failed to query Jamendo. Artist not found.");
                    }
                }
                return result;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to get Jamendo artist details", e);
            }
        }



    }
}
