using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
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

        public TrackSeeder(IUnitOfWork unitOfWork, IAlbumRepository albumRepository, IGenreRepository genreRepository, ITrackRepository trackRepository, IArtistRepository artistRepository) : base(unitOfWork)
        {
            _albumRepository = albumRepository;
            _genreRepository = genreRepository;
            _trackRepository = trackRepository;
            _artistRepository = artistRepository;
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

                // Get all media files
                var mediaFiles = await GetTracks();

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
                throw ex;
            }
        }

        public async Task<List<string>> GetTracks()
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

            return mediaFiles;
        }

        public async Task<HttpResponseMessage> UploadTrack(string filePath, int artistId, int trackId)
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

                var response = await httpClient.PostAsync("https://localhost:7151/api/Tracks/UploadTrack", content);
                return response;
            }
        }
    }
}

//// For each album, create a few tracks
//foreach (var album in albums)
//{
//    // For each genre, create a track
//    foreach (var genre in genres)
//    {
//        tracks.Add(new Track
//        {
//            Title = $"Epic Journey Through {genre.Name}",
//            AlbumId = album.Id,
//            GenreId = genre.Id,
//            Artist = album.Artist
//        });

//        tracks.Add(new Track
//        {
//            Title = $"Mystical Echoes of {album.Title}",
//            AlbumId = album.Id,
//            GenreId = genre.Id,
//            Artist = album.Artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"Soulful Rhythms of {album.Title}",
//            AlbumId = album.Id,
//            GenreId = genre.Id,
//            Artist = album.Artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Concerto",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = album.Artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} beneath",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = album.Artist
//        });
//    }
//}

//// Create tracks that don't belong to any album
//// For each artist from the albums, create a few tracks
// var artists = albums.Select(a => a.Artist).Distinct().ToList();

//foreach (var artist in artists)
//{
//    // For each genre, create a track
//    foreach (var genre in genres)
//    {
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Symphony",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });

//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Overture",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Sonata",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"Its {genre.Name} time!",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Rhapsody",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Nocturne",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Etude",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//        tracks.Add(new Track
//        {
//            Title = $"The {genre.Name} Prelude",
//            AlbumId = null,
//            GenreId = genre.Id,
//            Artist = artist
//        });
//    }
//}