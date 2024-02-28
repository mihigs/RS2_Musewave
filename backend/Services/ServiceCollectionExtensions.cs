using Microsoft.Extensions.DependencyInjection;
using Services.Implementations;
using Services.Interfaces;

namespace Services
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            services.AddScoped<IAlbumService, AlbumService>();
            services.AddScoped<IArtistService, ArtistService>();
            services.AddScoped<IGenreService, GenreService>();
            services.AddScoped<IPlaylistService, PlaylistService>();
            services.AddScoped<ITracksService, TracksService>();
            services.AddScoped<IUsersService, UsersService>();

            return services;
        }
    }
}
