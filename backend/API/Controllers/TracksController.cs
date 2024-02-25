using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using DataContext;
using Microsoft.AspNetCore.Authorization;
using Models.DTOs;
using Services.Implementations;
using DataContext.Repositories.Interfaces;
using DataContext.Repositories;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TracksController : ControllerBase
    {
        private readonly MusewaveDbContext _context;
        private readonly ITrackRepository _trackRepository;
        private readonly IUnitOfWork _unitOfWork;
        public TracksController(MusewaveDbContext context, ITrackRepository trackRepository, IUnitOfWork unitOfWork)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _trackRepository = trackRepository ?? throw new ArgumentNullException(nameof(trackRepository));
            _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
        }

        // get tracks by userId
        [HttpGet("GetLikedTracks")]
        public async Task<ApiResponse> GetLikedTracks()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _trackRepository.GetLikedTracksAsync(userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                // Log error
                throw;
            }
            return apiResponse;
        }
    }
}
