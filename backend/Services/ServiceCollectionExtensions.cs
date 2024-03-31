using Microsoft.Extensions.DependencyInjection;
using RabbitMQ.Client;
using Services.Implementations;
using Services.Interfaces;

namespace Services
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            services.AddScoped<IListenerService, ListenerService>();
            services.AddScoped<IAlbumService, AlbumService>();
            services.AddScoped<IArtistService, ArtistService>();
            services.AddScoped<IGenreService, GenreService>();
            services.AddScoped<IPlaylistService, PlaylistService>();
            services.AddScoped<ITracksService, TracksService>();
            services.AddScoped<IUsersService, UsersService>();
            services.AddScoped<IJamendoService, JamendoService>();

            return services;
        }

        public static IServiceCollection AddRabbitMqServices(this IServiceCollection services)
        {
            services.AddSingleton<IRabbitMqService, RabbitMqService>();
            services.AddHostedService<RabbitMqListener>();

            return services;
        }
    }
}
