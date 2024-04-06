using Azure;
using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Models.Entities;
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

        public JamendoService(IConfiguration configuration, ITrackRepository trackRepository, IArtistRepository artistRepository, IGenreRepository genreRepository, ILikeRepository likeRepository)
        {
            _configuration = configuration;
            _trackRepository = trackRepository;
            _artistRepository = artistRepository;
            _genreRepository = genreRepository;
            _likeRepository = likeRepository;
        }

        public async Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName, string userId)
        {
            try
            {
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"?client_id={_configuration["Jamendo:ClientId"]}&include=musicinfo&format=jsonpretty&name={trackName}").Result;
                if (response.IsSuccessStatusCode)
                {
                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiResponse(serializedResponse);
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

        public async Task<Track?> MapJamendoResponseToTrack(JamendoResult? response, string? userId = null)
        {
            if (response != null)
            {
                // Check if track already exists in the database
                var existingTrack = await _trackRepository.GetByJamendoId(response.Id);
                if (existingTrack != null)
                {
                    // Check if the track is liked by the user
                    if(userId != null)
                    {
                        existingTrack.IsLiked = await CheckIfTrackIsLikedByUser(existingTrack.Id, userId) != null;
                    }
                    return existingTrack;
                }
                var track = new Track
                {
                    JamendoId = response.Id,
                    Title = response.Name,
                    Duration = response.Duration,
                    ImageUrl = response.Image,
                    SignedUrl = response.Audio,
                };

                if (response.ArtistId != null)
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

        public JamendoApiResponse MapJamendoApiResponse(string response)
        {
            // Deserialize the response into JamendoApiResponse object
            var jamendoApiResponse = JsonSerializer.Deserialize<JamendoApiResponse>(response);

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
                } else
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
                    var response = client.GetAsync($"?client_id={_configuration["Jamendo:ClientId"]}&include=musicinfo&format=jsonpretty&id={trackId}").Result;
                    if (response.IsSuccessStatusCode)
                    {
                        var serializedResponse = response.Content.ReadAsStringAsync().Result;
                        var result = MapJamendoApiResponse(serializedResponse);
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
                var response = client.GetAsync($"?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&limit=5&include=musicinfo&tags={tags}").Result;
                if (response.IsSuccessStatusCode)
                {
                    var serializedResponse = await response.Content.ReadAsStringAsync();
                    var deserializedResponse = MapJamendoApiResponse(serializedResponse);
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


    }
}
