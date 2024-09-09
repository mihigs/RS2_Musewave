using Microsoft.Extensions.DependencyInjection;
using Services.Implementations.BackgroundServices;
using Services.Interfaces;
using StackExchange.Redis;

namespace Services.Implementations
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
            services.AddScoped<IAdminService, AdminService>();
            services.AddScoped<IGenreSimilarityTrackerService, GenreSimilarityTrackerService>();
            services.AddScoped<IExploreWeeklyGenerator, ExploreWeeklyGenerator>();
            services.AddScoped<ISearchService, SearchService>();
            services.AddScoped<IPaymentsService, PaymentsService>();
            services.AddScoped<ILanguageService, LanguageService>();

            return services;
        }

        public static IServiceCollection AddBackgroundServices(this IServiceCollection services)
        {
            services.AddSingleton<ServiceRunControl>();
            services.AddHostedService<JamendoBackgroundService>();
            services.AddHostedService<GenreSimilarityTracker>();
            services.AddHostedService<ExploreWeeklyPlaylistGenerator>();

            return services;
        }

        public static IServiceCollection AddRabbitMqServices(this IServiceCollection services)
        {
            services.AddSingleton<IRabbitMqService, RabbitMqService>();
            services.AddHostedService<RabbitMqListener>();

            return services;
        }

        public static IServiceCollection AddRedisServices(this IServiceCollection services, string connectionString)
        {
            services.AddSingleton<IConnectionMultiplexer>(ConnectionMultiplexer.Connect(connectionString));
            services.AddSingleton<IRedisService, RedisService>();

            return services;
        }
    }
}
