﻿using DataContext.Repositories.Interfaces;

namespace DataContext.Repositories
{
    public class UserRepository : Repository<IUserRepository>
    {
        private readonly MusewaveDbContext _dbContext;
        public UserRepository(MusewaveDbContext dbContext) : base(dbContext)
        {
            _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
        }
    }
}
