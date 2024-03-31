using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.Configuration;
using Models.Entities;
using Services.Interfaces;
using System.Text.Json;
using static Models.DTOs.JamendoApiDto;

namespace Services.Implementations
{
    public class JamendoService : IJamendoService
    {
        private readonly IConfiguration _configuration;

        public JamendoService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public Task<IEnumerable<Track>> SearchJamendoByTrackName(string trackName)
        {
            try
            {
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&name={trackName}").Result;
                if (response.IsSuccessStatusCode)
                {
                    var serializedResponse = response.Content.ReadAsStringAsync().Result;
                    var result = MapJamendoApiResponse(serializedResponse);
                    var tracks = result.Results.Select(MapJamendoResponseToTrack);

                    return Task.FromResult(tracks);
                }
                else
                {
                    throw new Exception("Failed to search Jamendo by track name");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to search Jamendo by track name", e);
            }
        }

        public Task<Track> GetTrackById(int trackId)
        {
            try
            {
                using var client = new HttpClient();
                client.BaseAddress = new Uri(_configuration["Jamendo:BaseUrl"]);
                var response = client.GetAsync($"?client_id={_configuration["Jamendo:ClientId"]}&format=jsonpretty&id={trackId}").Result;
                if (response.IsSuccessStatusCode)
                {
                    var serializedResponse = response.Content.ReadAsStringAsync().Result;
                    var result = MapJamendoApiResponse(serializedResponse);
                    var track = MapJamendoResponseToTrack(result.Results.FirstOrDefault());

                    return Task.FromResult(track);
                }
                else
                {
                    throw new Exception("Failed to get Jamendo track by id");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw new Exception("Failed to get Jamendo track by id", e);
            }
        }

        public Track MapJamendoResponseToTrack(JamendoResult response)
        {
            var track = new Track
            {
                JamendoId = response.Id,
                Title = response.Name,
                Duration = response.Duration,
                ImageUrl = response.Image,
                SignedUrl = response.Audio,
                //AlbumId = response.AlbumId,
                //ArtistId = response.ArtistId,
                //GenreId = response.GenreId,
                //FilePath = response.FilePath,
            };

            if (response.ArtistId != null)
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
            }

            return track;
        }

        public JamendoApiResponse MapJamendoApiResponse(string response)
        {
            // Deserialize the response into JamendoApiResponse object
            var jamendoApiResponse = JsonSerializer.Deserialize<JamendoApiResponse>(response);

            // Check if the deserialization was successful
            if (jamendoApiResponse == null || jamendoApiResponse.Results == null)
            {
                throw new JsonException("Failed to deserialize Jamendo API response.");
            }

            // Process each result and map it to Track
            var tracks = new List<Track>();
            foreach (var result in jamendoApiResponse.Results)
            {
                var track = MapJamendoResponseToTrack(result);
                tracks.Add(track);
            }

            // Optionally, process these tracks, save them to the database, etc.

            return jamendoApiResponse;
        }

    }
}
