﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Models.DTOs;
using DataContext.Repositories;
using System.Security.Claims;
using Services.Interfaces;
using Services.Implementations;
using System.Linq;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Models.Entities;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TracksController : ControllerBase
    {
        private readonly ITracksService _tracksService;
        private readonly IListenerService _listenerService;
        private readonly IJamendoService _jamendoService;

        public TracksController(ITracksService tracksService, IListenerService listenerService, IJamendoService jamendoService)
        {
            _tracksService = tracksService ?? throw new ArgumentNullException(nameof(tracksService));
            _listenerService = listenerService ?? throw new ArgumentNullException(nameof(listenerService));
            _jamendoService = jamendoService;
        }

        [HttpGet("GetLikedTracks")]
        public async Task<ApiResponse> GetLikedTracks()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.GetLikedTracksAsync(userId);
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

        [HttpGet("GetTracksByName")]
        public async Task<ApiResponse> GetTracksByName(string name)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _tracksService.GetTracksByNameAsync(name);
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

        [HttpGet("GetJamendoTracksByName")]
        public async Task<ApiResponse> GetJamendoTracksByName(string name)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // Get the userId from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return apiResponse;
                }
                var userId = userIdClaim.Value;
                apiResponse.Data = await _jamendoService.SearchJamendoByTrackName(name, userId);
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

        [HttpPost("UploadTrack")]
        public async Task<IActionResult> UploadTrack(TrackUploadDetailsDto model)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // Check if file is not empty
                if (model.mediaFile is null || model.mediaFile.Length == 0)
                {
                    return BadRequest("File cannot be empty");
                }
                // Check if trackName is not empty
                if (string.IsNullOrWhiteSpace(model.trackName))
                {
                    return BadRequest("Track name cannot be empty");
                }
                // Check if userId is not empty
                if (string.IsNullOrWhiteSpace(model.userId))
                {
                    return BadRequest("User ID cannot be empty");
                }
                // Check if file size is less than 10MB
                if (model.mediaFile.Length > 10 * 1024 * 1024) // 10MB in bytes
                {
                    return BadRequest("File size cannot exceed 10MB");
                }

                // Check if file type is .mp3, .midi, .mid or .wav
                var allowedExtensions = new[] { ".mp3", ".midi", ".mid", ".wav" };
                var fileExtension = Path.GetExtension(model.mediaFile.FileName).ToLower();

                if (!allowedExtensions.Contains(fileExtension))
                {
                    return BadRequest("Invalid file type. Only .mp3, .midi, .mid and .wav files are allowed");
                }

                // If file is valid, send it to the Listener to be processed
                await _listenerService.TrackUploadRequest(model);

                // Return a 201 Created response
                apiResponse.StatusCode = System.Net.HttpStatusCode.Created;
                return CreatedAtAction(nameof(UploadTrack), apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpGet("GetTrack/{trackId}")]
        public async Task<IActionResult> GetTrack(int trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                Track trackResult = null;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim != null)
                {
                    string userId = userIdClaim.Value;
                    trackResult = await _tracksService.GetTrackByIdAsync(trackId, userId);
                }
                if (trackResult is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Track not found");
                    return NotFound(apiResponse);
                }

                apiResponse.Data = trackResult;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        //GetJamendoTrack
        [HttpGet("GetJamendoTrack/{jamendoId}")]
        public async Task<IActionResult> GetJamendoTrack(int jamendoId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                var trackResult = await _jamendoService.GetTrackById(jamendoId, userId);
                if (trackResult is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Jamendo track not found");
                    return NotFound(apiResponse);
                }

                apiResponse.Data = trackResult;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpPost("GetNextTrack")]
        public async Task<IActionResult> GetNextTrack([FromBody] GetNextTrackRequestDto getNextTrackDto)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                // gets the user id from the token
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                // gets the next track based on the streaming context type
                var nextTrack = await _tracksService.GetNextTrackAsync(getNextTrackDto, userId);
                if (nextTrack is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
                    apiResponse.Errors.Add("Track not found");
                    return NotFound(apiResponse);
                }
                apiResponse.Data = nextTrack;
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                return StatusCode((int)apiResponse.StatusCode, apiResponse);
            }
        }


        //[HttpGet("GetNextTrack/{currentTrackId}")]
        //public async Task<IActionResult> GetNextTrack(int currentTrackId)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var nextTrack = await _tracksService.GetNextTrackAsync(currentTrackId);
        //        if (nextTrack is null)
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            apiResponse.Errors.Add("Track not found");
        //        }
        //        apiResponse.Data = nextTrack;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //        return Ok(apiResponse);
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //}

        //[HttpGet("GetNextPlaylistTrack/{currentTrackId}/{playlistId}")]
        //public async Task<IActionResult> GetNextPlaylistTrack(int currentTrackId, int playlistId)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var nextTrack = await _tracksService.GetNextPlaylistTrackAsync(currentTrackId, playlistId);
        //        if (nextTrack is null)
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            apiResponse.Errors.Add("Track not found");
        //        }
        //        apiResponse.Data = nextTrack;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //        return Ok(apiResponse);
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //}

        //[HttpGet("GetNextAlbumTrack/{currentTrackId}/{albumId}")]
        //public async Task<IActionResult> GetNextAlbumTrack(int currentTrackId, int albumId)
        //{
        //    ApiResponse apiResponse = new ApiResponse();
        //    try
        //    {
        //        var nextTrack = await _tracksService.GetNextAlbumTrackAsync(currentTrackId, albumId);
        //        if (nextTrack is null)
        //        {
        //            apiResponse.StatusCode = System.Net.HttpStatusCode.NotFound;
        //            apiResponse.Errors.Add("Track not found");
        //        }
        //        apiResponse.Data = nextTrack;
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
        //        return Ok(apiResponse);
        //    }
        //    catch (Exception ex)
        //    {
        //        apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
        //        apiResponse.Errors.Add(ex.Message);
        //        throw;
        //    }
        //}

        // a controller endpoint that takes a trackId, gets the userId from the token, and calls the service to like the track
        [HttpPost("ToggleLikeTrack/{trackId}")]
        public async Task<IActionResult> ToggleLikeTrack(int trackId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.ToggleLikeTrack(trackId, userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
                return Ok(apiResponse);
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
        }

        [HttpGet("GetTracksByArtist/{artistId}")]
        public async Task<IActionResult> GetTracksByArtistId(int artistId)
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                apiResponse.Data = await _tracksService.GetTracksByArtistId(artistId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return Ok(apiResponse);
        }

        [HttpGet("GetTracksByUser")]
        public async Task<IActionResult> GetTracksByUser()
        {
            ApiResponse apiResponse = new ApiResponse();
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim is null)
                {
                    apiResponse.StatusCode = System.Net.HttpStatusCode.BadRequest;
                    apiResponse.Errors.Add("User not found");
                    return BadRequest(apiResponse);
                }
                string userId = userIdClaim.Value;
                apiResponse.Data = await _tracksService.GetTracksByUserId(userId);
                apiResponse.StatusCode = System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                apiResponse.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                apiResponse.Errors.Add(ex.Message);
                throw;
            }
            return Ok(apiResponse);
        }

    }
}