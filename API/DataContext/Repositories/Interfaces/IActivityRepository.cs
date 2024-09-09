using Models.Entities;
using Models.Enums;

namespace DataContext.Repositories.Interfaces
{
    public interface IActivityRepository : IRepository<Activity>
    {
        public Task AddActivity(string userId, ActivityType activityType, bool? isSuccessful);
        public Task<int> GetDailyLoginCount();
        public Task<int> GetJamendoAPIRequestCountPerMonth();
    }
}
