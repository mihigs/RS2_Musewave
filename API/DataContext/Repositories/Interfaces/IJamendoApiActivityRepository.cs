using Models.Entities;
using Models.Enums;

namespace DataContext.Repositories.Interfaces
{
    public interface IJamendoApiActivityRepository : IRepository<JamendoAPIActivity>
    {
        Task AddJamendoApiActivity(JamendoAPIActivityType activityType, string? userId = null);
        Task<int> GetJamendoAPIRequestCountPerMonth();
    }
}
