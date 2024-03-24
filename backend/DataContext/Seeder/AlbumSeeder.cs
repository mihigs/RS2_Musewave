using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Seeder
{
    internal class AlbumSeeder : BaseSeeder
    {
        private readonly IArtistRepository _artistRepository;
        private readonly IAlbumRepository _albumRepository;

        public AlbumSeeder(IUnitOfWork unitOfWork, IArtistRepository artistRepository, IAlbumRepository albumRepository) : base(unitOfWork)
        {
            _artistRepository = artistRepository;
            _albumRepository = albumRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Fetch all artists including users from the database
                var artists = await _artistRepository.GetAllIncluding(["User"]);

                if (artists == null || artists.Count() == 0)
                {
                    Console.WriteLine("No artists found in the database. Skipping album seeding.");
                    return false;
                }

                // Create a list to hold the albums
                List<Album> albums = new List<Album>();

                // For each artist, create a few albums
                foreach (var artist in artists)
                {
                    albums.Add(new Album
                    {
                        Title = $"Album 1 by {artist.User.UserName}",
                        ArtistId = artist.Id
                    });

                    albums.Add(new Album
                    {
                        Title = $"Album 2 by {artist.User.UserName}",
                        ArtistId = artist.Id
                    });
                    albums.Add(new Album
                    {
                        Title = $"Album 3 by {artist.User.UserName}",
                        ArtistId = artist.Id
                    });
                    albums.Add(new Album
                    {
                        Title = $"Album 4 by {artist.User.UserName}",
                        ArtistId = artist.Id
                    });
                }

                // Add the albums to the database
                await _albumRepository.AddRange(albums);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"AlbumSeeder failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
