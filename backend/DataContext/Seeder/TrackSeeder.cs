﻿using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.Configuration;
using Models.DTOs;
using Models.Entities;
using System.Globalization;
using System.Net.Http.Headers;

namespace DataContext.Seeder
{
    internal class TrackSeeder : BaseSeeder
    {
        private string sourceDir = Path.Combine(Directory.GetCurrentDirectory(), "Seeder", "Tracks");
        private readonly IAlbumRepository _albumRepository;
        private readonly IGenreRepository _genreRepository;
        private readonly ITrackRepository _trackRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IConfiguration _configuration;

        public TrackSeeder(IUnitOfWork unitOfWork, IAlbumRepository albumRepository, IGenreRepository genreRepository, ITrackRepository trackRepository, IArtistRepository artistRepository, IConfiguration configuration) : base(unitOfWork)
        {
            _albumRepository = albumRepository;
            _genreRepository = genreRepository;
            _trackRepository = trackRepository;
            _artistRepository = artistRepository;
            _configuration = configuration;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Fetch all albums and genres from the database
                var albums = await _albumRepository.GetAll();
                var genres = await _genreRepository.GetAll();
                var artists = await _artistRepository.GetAll();

                // Create a list to hold the tracks
                //List<Track> tracks = new List<Track>();

                // Log the source directory
                Console.WriteLine($"Source directory: {sourceDir}");

                // Get all media files
                var mediaFiles = await GetTracks();

                // Check if there are any media files
                if (mediaFiles.Count == 0)
                {
                    Console.WriteLine("No media files found.");
                    return false;
                }

                // Create a random number generator
                var rng = new Random();

                foreach (var mediaFile in mediaFiles)
                {
                    // Create a new Track entity
                    var track = new Track();

                    // Set the title to the file name, capitalised, without dashes
                    var fileName = Path.GetFileNameWithoutExtension(mediaFile);
                    track.Title = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(fileName.Replace("-", " "));

                    // Set the duration (you might need a library to read the duration from the file)
                    // track.Duration = GetDuration(mediaFile);

                    // Assign a random artistId, albumId, and genreId to the track
                    track.ArtistId = artists.ToList()[rng.Next(artists.Count())].Id;
                    track.AlbumId = albums.ToList()[rng.Next(albums.Count())].Id;
                    track.GenreId = genres.ToList()[rng.Next(genres.Count())].Id;

                    // Add the track to the list
                    //tracks.Add(track);

                    // Add the tracks to the database
                    await _trackRepository.Add(track);

                    // Upload tracks to the Listener
                    var response = await UploadTrack(mediaFile, track.ArtistId, track.Id);
                    if (!response.IsSuccessStatusCode)
                    {
                        throw new Exception("Failed to upload track to the Listener.");
                    }
                }

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"TrackSeeder failed: {ex.Message}");
                throw ex;
            }
        }

        public async Task<List<string>> GetTracks()
        {
            try
            {
                var mediaFiles = new List<string>();

                // Check if the directory exists
                if (Directory.Exists(sourceDir))
                {
                    // Get all media files (you can add more extensions if needed)
                    var fileExtensions = new string[] { ".mp3", ".wav" };
                    foreach (var extension in fileExtensions)
                    {
                        mediaFiles.AddRange(Directory.EnumerateFiles(sourceDir, $"*{extension}", SearchOption.AllDirectories));
                    }
                }
                else
                {
                    Console.WriteLine("Directory not found.");
                }

                return mediaFiles;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"GetTracks failed: {ex.Message}");
                throw ex;
            }
        }

        public async Task<HttpResponseMessage> UploadTrack(string filePath, int artistId, int trackId)
        {
            try
            {
                using (var httpClient = new HttpClient())
                {
                    var fileStream = System.IO.File.OpenRead(filePath);
                    var content = new MultipartFormDataContent();
                    content.Add(new StreamContent(fileStream)
                    {
                        Headers =
                    {
                        ContentLength = fileStream.Length,
                        ContentType = new MediaTypeHeaderValue("application/octet-stream")
                    }
                    }, "mediaFile", Path.GetFileName(filePath));

                    // Add artistId and trackId to the content
                    content.Add(new StringContent(artistId.ToString()), "artistId");
                    content.Add(new StringContent(trackId.ToString()), "trackId");

                    Console.WriteLine($"Listener URL: {_configuration["ListenerApiUrl"]}/Tracks/UploadTrack");

                    var response = await httpClient.PostAsync($"{_configuration["ListenerApiUrl"]}/Tracks/UploadTrack", content);

                    return response;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine($"UploadTrack failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
