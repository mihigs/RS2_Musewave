using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface ICommentRepository : IRepository<Comment>
    {
        Task<IEnumerable<Comment>> GetTrackComments(int trackId);
    }
}
