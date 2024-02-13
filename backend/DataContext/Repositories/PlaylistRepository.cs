using DataContext.Repositories.Interfaces;
using Models.Entities;

namespace DataContext.Repositories
{
    public class PlaylistRepository : Repository<Playlist>, IPlaylistRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public PlaylistRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
