using Microsoft.EntityFrameworkCore;
namespace DataContext.Repositories
{
    public class Repository<T> : IRepository<T> where T : class
    {
        private readonly MusewaveDbContext _context;
        public Repository(MusewaveDbContext context)
        {
            _context = context;
        }
        public virtual async Task<T> Add(T entity)
        {
            _context.Set<T>().Add(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task<T> Remove(int id)
        {
            var entity = await _context.Set<T>().FindAsync(id);
            if (entity is null)
            {
                return null;
            }

            _context.Set<T>().Remove(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task<IEnumerable<T>> GetAll()
        {
            return await _context.Set<T>().ToListAsync();
        }

        public virtual async Task<T> GetById(int id)
        {
            return await _context.Set<T>().FindAsync(id);
        }

        public virtual async Task<T> Update(T entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task<IEnumerable<T>> AddRange(IEnumerable<T> entities)
        {
            _context.Set<T>().AddRange(entities);
            await _context.SaveChangesAsync();
            return entities;
        }

        public virtual async Task<IEnumerable<T>> UpdateRange(IEnumerable<T> entities)
        {
            _context.Set<T>().UpdateRange(entities);
            await _context.SaveChangesAsync();
            return entities;
        }

        public virtual async Task<IEnumerable<T>> RemoveRange(IEnumerable<T> entities)
        {
            _context.Set<T>().RemoveRange(entities);
            await _context.SaveChangesAsync();
            return entities;
        }

        public virtual async Task<IEnumerable<T>> GetAllIncluding(string[] includes)
        {
            var query = _context.Set<T>().AsQueryable();
            foreach (var include in includes)
            {
                query = query.Include(include);
            }
            return await query.ToListAsync();
        }

    }
}
