﻿using Models.Entities;

namespace DataContext.Repositories.Interfaces
{
    public interface IArtistRepository : IRepository<Artist>
    {
        Task<IEnumerable<Artist>> GetArtistsByNameAsync(string name);
    }
}
