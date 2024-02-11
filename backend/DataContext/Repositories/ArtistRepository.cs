using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models;

namespace DataContext.Repositories
{
    public class ArtistRepository : IArtistRepository
    {
        private readonly MusewaveDbContext _context;
        public ArtistRepository(MusewaveDbContext musewaveDbContext) {
            _context = musewaveDbContext;
        }

        public Task<Artist> Add(Artist entity)
        {
            throw new NotImplementedException();
        }

        public async Task<IEnumerable<Artist>> AddRange(IEnumerable<Artist> entities)
        {
            await _context.Set<Artist>().AddRangeAsync(entities);
            await _context.SaveChangesAsync();
            return entities;
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
