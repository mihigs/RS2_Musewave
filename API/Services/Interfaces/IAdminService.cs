using Models.DTOs;

namespace Services.Interfaces
{
    public interface IAdminService
    {
        Task<AdminDashboardDetailsDto> GetDashboardDetails();
    }
}
