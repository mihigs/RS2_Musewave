﻿using Playlist = Models.Entities.Playlist;

namespace Services.Interfaces
{
    public interface IPlaylistService
    {
        Task<IEnumerable<Playlist>> GetPlaylistsByNameAsync(string name, bool arePublic = true);
        Task<Playlist> GetPlaylistDetailsAsync(int id, string userId);
        Task<IEnumerable<Playlist>> GetPlaylistsByUserIdAsync(string userId);
    }
}
