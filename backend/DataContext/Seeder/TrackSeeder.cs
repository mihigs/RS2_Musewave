using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Seeder
{
    internal class TrackSeeder : BaseSeeder
    {
        private readonly IAlbumRepository _albumRepository;
        private readonly IGenreRepository _genreRepository;
        private readonly ITrackRepository _trackRepository;

        public TrackSeeder(IUnitOfWork unitOfWork, IAlbumRepository albumRepository, IGenreRepository genreRepository, ITrackRepository trackRepository) : base(unitOfWork)
        {
            _albumRepository = albumRepository;
            _genreRepository = genreRepository;
            _trackRepository = trackRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Fetch all albums and genres from the database
                var albums = await _albumRepository.GetAll();
                var genres = await _genreRepository.GetAll();

                // Create a list to hold the tracks
                List<Track> tracks = new List<Track>();

                // For each album, create a few tracks
                foreach (var album in albums)
                {
                    // For each genre, create a track
                    foreach (var genre in genres)
                    {
                        tracks.Add(new Track
                        {
                            Title = $"Epic Journey Through {genre.Name}",
                            AlbumId = album.Id,
                            GenreId = genre.Id
                        });

                        tracks.Add(new Track
                        {
                            Title = $"Mystical Echoes of {album.Title}",
                            AlbumId = album.Id,
                            GenreId = genre.Id
                        });
                        tracks.Add(new Track
                        {
                            Title = $"Soulful Rhythms of {album.Title}",
                            AlbumId = album.Id,
                            GenreId = genre.Id
                        });
                        tracks.Add(new Track
                        {
                            Title = $"The {genre.Name} Concerto",
                            AlbumId = null,
                            GenreId = genre.Id
                        });
                        tracks.Add(new Track
                        {
                            Title = $"The {genre.Name} beneath",
                            AlbumId = null,
                            GenreId = genre.Id
                        });
                    }
                }

                // Create tracks that don't belong to any album
                foreach (var genre in genres)
                {
                    tracks.Add(new Track
                    {
                        Title = $"Unchained Melody of {genre.Name}",
                        AlbumId = null,
                        GenreId = genre.Id
                    });

                    tracks.Add(new Track
                    {
                        Title = $"Lonely Ballad in {genre.Name}",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"{genre.Name} time",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Symphony",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Overture",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Sonata",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"Its {genre.Name} time!",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Rhapsody",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Nocturne",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Etude",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                    tracks.Add(new Track
                    {
                        Title = $"The {genre.Name} Prelude",
                        AlbumId = null,
                        GenreId = genre.Id
                    });
                }

                // Add the tracks to the database
                await _trackRepository.AddRange(tracks);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                throw ex;
            }
        }
    }
}
