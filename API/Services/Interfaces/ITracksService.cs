﻿using Models.DTOs;
using Models.Entities;

namespace Services.Interfaces
{
    public interface ITracksService
    {
        Task<IEnumerable<Track>> GetLikedTracksAsync(string userId);
        Task<IEnumerable<Track>> GetTracksByNameAsync(string name);
        Task<Track> InitializeTrack(Track track);
        //Task<Track> handleListenerDoneProcessing(RabbitMqMessage messageObject);
        Task<Track> GetTrackByIdAsync(int trackId, string userId);
        string GenerateSignedTrackUrl(string listenerTrackId, string artistId);
        Task<Track> GetNextTrackAsync(GetNextTrackRequestDto getNextTrackDto, string userId);
        //Task<Track> GetNextJamendoTrackAsync(int currentTrackId, string userId);
        Task<Like?> ToggleLikeTrack(int trackId, string userId);
        Task<Like?> CheckIfTrackIsLikedByUser(int trackId, string userId);
        Task<List<Track>> GetTracksByArtistId(int artistId);
        Task<List<Track>> GetTracksByUserId(string userId);
    }
}