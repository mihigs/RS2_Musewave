﻿using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext.Repositories
{
    public class ArtistRepository : Repository<Artist>, IArtistRepository
    {
        private readonly MusewaveDbContext _dbContext;
        public ArtistRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }

        public async Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name)
        {
            return await _dbContext.Set<Artist>()
                .Where(a => a.User.UserName.Contains(name))
                .Include(a => a.User)
                .ToListAsync();
        }

        public async Task<Artist> GetArtistByUserId(string userId)
        {
            return _dbContext.Set<Artist>()
                .Include(a => a.User)
                .FirstOrDefault(a => a.UserId == userId);
        }

        public async Task<int> GetArtistCount(int? month = null, int? year = null)
        {
            return await _dbContext.Set<Artist>()
                .Where(a =>
                    (month == null || a.CreatedAt.Month == month.Value) &&
                    (year == null || a.CreatedAt.Year == year.Value))
                .CountAsync();
        }

        public async Task<Artist?> GetArtistByJamendoId(string jamendoArtistId)
        {
            return await _dbContext.Set<Artist>()
                .FirstOrDefaultAsync(a => a.JamendoArtistId == jamendoArtistId);
        }

        public async Task<Artist> GetArtistDetailsAsync(int artistId)
        {
            return await _dbContext.Set<Artist>()
                .Include(a => a.User)
                .FirstOrDefaultAsync(a => a.Id == artistId);
        }
    }
}
