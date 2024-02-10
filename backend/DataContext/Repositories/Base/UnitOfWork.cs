namespace DataContext.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly MusewaveDbContext _context;
        public UnitOfWork(MusewaveDbContext context)
        {
            _context = context;
        }
        public void Dispose()
        {
            _context.Dispose();
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }
    }
}
