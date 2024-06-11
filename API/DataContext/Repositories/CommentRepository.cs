using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class CommentRepository : Repository<Comment>, ICommentRepository
    {
        private readonly MusewaveDbContext _dbContext;

        public CommentRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Comment>> GetTrackComments(int trackId)
        {
            return _dbContext.Set<Comment>()
                .Where(c => c.TrackId == trackId)
                .Include(c => c.User)
                .OrderByDescending(c => c.CreatedAt);
        }
    }
}
