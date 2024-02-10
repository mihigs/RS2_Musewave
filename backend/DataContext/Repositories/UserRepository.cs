using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models;

namespace DataContext.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly MusewaveDbContext _context;
        public UserRepository(MusewaveDbContext musewaveDbContext) {
            _context = musewaveDbContext;
        }

        public async Task<User> Add(User entity)
        {
            _context.Set<User>().Add(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public async Task<IEnumerable<User>> AddRange(IEnumerable<User> entities)
        {
            await _context.Set<User>().AddRangeAsync(entities);
            await _context.SaveChangesAsync();
            return entities;
        }

        public Task<IEnumerable<User>> GetAll()
        {
            throw new NotImplementedException();
        }

        public Task<User> GetById(int id)
        {
            throw new NotImplementedException();
        }

        public Task<User> Remove(int id)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<User>> RemoveRange(IEnumerable<User> entities)
        {
            throw new NotImplementedException();
        }

        public Task<User> Update(User entity)
        {
            throw new NotImplementedException();
        }

        public Task<IEnumerable<User>> UpdateRange(IEnumerable<User> entities)
        {
            throw new NotImplementedException();
        }
    }
}
