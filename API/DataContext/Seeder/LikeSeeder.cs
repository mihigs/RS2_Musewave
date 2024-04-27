using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Seeder
{
    internal class LikeSeeder
    {
        private readonly IUserRepository _userRepository;
        private readonly ITrackRepository _trackRepository;
        private readonly ILikeRepository _likeRepository;

        public LikeSeeder(IUserRepository userRepository, ITrackRepository trackRepository, ILikeRepository likeRepository) 
        {
            _userRepository = userRepository;
            _trackRepository = trackRepository;
            _likeRepository = likeRepository;
        }

        public async Task<bool> Seed()
        {
            try
            {
                // Fetch all users and tracks from the database
                var users = await _userRepository.GetAll();
                var tracks = await _trackRepository.GetAll();

                // Create a list to hold the likes
                List<Like> likes = new List<Like>();

                // For each user, create likes based on the like modifier
                foreach (var user in users)
                {
                    // Generate a random like modifier [0-6]
                    var likeModifier = new Random().Next(0, 7);

                    if (likeModifier == 0)
                    {
                        // The user doesn't like anything
                        continue;
                    }
                    else if (likeModifier >= 1 && likeModifier <= 5)
                    {
                        // The user will like random half of the tracks on the platform
                        var likedTracks = tracks.OrderBy(x => Guid.NewGuid()).Take(tracks.Count() / 2);

                        foreach (var track in likedTracks)
                        {
                            likes.Add(new Like
                            {
                                UserId = user.Id,
                                TrackId = track.Id
                            });
                        }
                    }
                    else if (likeModifier == 6)
                    {
                        // The user will like everything on the platform
                        foreach (var track in tracks)
                        {
                            likes.Add(new Like
                            {
                                UserId = user.Id,
                                TrackId = track.Id
                            });
                        }
                    }
                }

                // Add the likes to the database
                await _likeRepository.AddRange(likes);

                return true;
            }
            catch (Exception ex)
            {
                // Log error
                Console.WriteLine($"LikeSeeder failed: {ex.Message}");
                throw ex;
            }
        }
    }
}
