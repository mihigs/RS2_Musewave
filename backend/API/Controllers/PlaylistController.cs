﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Models.Entities;
using Services.Interfaces;
using System.Security.Claims;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class PlaylistController : ControllerBase
    {
        private readonly IPlaylistService _playlistService;

        public PlaylistController(IPlaylistService playlistService)
        {
            _playlistService = playlistService ?? throw new ArgumentNullException(nameof(playlistService));
        }

        [HttpGet("GetPlaylistDetailsAsync/{playlistId}")]
        public async Task<ApiResponse> GetPlaylistDetailsAsync(int playlistId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // gets the user id from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _playlistService.GetPlaylistDetailsAsync(playlistId, userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }

        //[HttpGet]
        //public async Task<ApiResponse> GetAllPlaylists()
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        apiResponse.Data = await _playlistService.GetAllPlaylistsAsync();
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpGet("{id}")]
        //public async Task<ApiResponse> GetPlaylistById(int id)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        apiResponse.Data = await _playlistService.GetPlaylistByIdAsync(id);
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpPost]
        //public async Task<ApiResponse> AddPlaylist(Playlist playlist)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var addedPlaylist = await _playlistService.AddPlaylistAsync(playlist);
        //        apiResponse.Data = addedPlaylist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpPut("{id}")]
        //public async Task<ApiResponse> UpdatePlaylist(int id, Playlist playlist)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var updatedPlaylist = await _playlistService.UpdatePlaylistAsync(playlist);
        //        apiResponse.Data = updatedPlaylist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        //[HttpDelete("{id}")]
        //public async Task<ApiResponse> RemovePlaylist(int id)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var removedPlaylist = await _playlistService.RemovePlaylistAsync(id);
        //        if (removedPlaylist == null)
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            return apiResponse;
        //        }
        //        apiResponse.Data = removedPlaylist;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //    return apiResponse;
        //}

        [HttpGet("GetPlaylistsByName")]
        public async Task<ApiResponse> GetPlaylistsByName(string name)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _playlistService.GetPlaylistsByNameAsync(name);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return apiResponse;
        }
    }
}
