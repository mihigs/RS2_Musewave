using Models.DTOs;
using Models.DTOs.Queries;
using Models.Entities;

namespace Services.Interfaces
{
    public interface IAdminService
    {
        Task<AdminDashboardDetailsDto> GetDashboardDetails();
    }
}
