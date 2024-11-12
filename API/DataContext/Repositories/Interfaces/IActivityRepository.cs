using Models.Entities;
using Models.Enums;

namespace DataContext.Repositories.Interfaces
{
    public interface IActivityRepository : IRepository<Activity>
    {
        public Task AddActivity(string userId, ActivityType activityType, bool? isSuccessful);
        public Task<int> GetDailyLoginCount(int? month = null, int? year = null);
        public Task<int> GetJamendoAPIRequestCountPerMonth(int? month = null, int? year = null);
    }
}
