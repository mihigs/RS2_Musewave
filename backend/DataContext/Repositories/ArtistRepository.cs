using DataContext.Repositories.Interfaces;
using Models;

namespace DataContext.Repositories
{
    public class ArtistRepository : IArtistRepository
    {
        public ArtistRepository() { }

        public Task<Artist> Add(Artist entity)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Artist>> AddRange(IEnumerable<Artist> entities)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Artist>> GetAll()
        {
            throw new NotImplementedException();
        }

        public Task<Artist> GetById(int id)
        {
            throw new NotImplementedException();
        }

        public Task<Artist> Remove(int id)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Artist>> RemoveRange(IEnumerable<Artist> entities)
        {
            throw new NotImplementedException();
        }

        public Task<Artist> Update(Artist entity)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<Artist>> UpdateRange(IEnumerable<Artist> entities)
        {
            throw new NotImplementedException();
        }
    }
}
