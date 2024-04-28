using Models.DTOs;
using Models.Entities;
using Services.Responses;

namespace Services.Interfaces
{
    public interface IAdminService
    {
        Task<AdminDashboardDetailsDto> GetDashboardDetails();
    }
}
