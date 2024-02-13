using Microsoft.Extensions.DependencyInjection;
using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped<IAlbumRepository, AlbumRepository>();
            services.AddScoped<IArtistRepository, ArtistRepository>();
            services.AddScoped<IGenreRepository, GenreRepository>();
            services.AddScoped<ILikeRepository, LikeRepository>();
            services.AddScoped<IPlaylistRepository, PlaylistRepository>();
            services.AddScoped<ITrackRepository, TrackRepository>();
            services.AddScoped<IUserRepository, UserRepository>();

            return services;
        }
        public static IServiceCollection RegisterDbContext(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<MusewaveDbContext>(options =>
            {
                options.UseSqlServer(connectionString);
            }, ServiceLifetime.Scoped);

            return services;
        }
        public static IServiceCollection RegisterIdentity(this IServiceCollection services)
        {

            services.AddIdentityCore<User>(options =>
            {
                options.User.RequireUniqueEmail = false;
            })
            .AddEntityFrameworkStores<MusewaveDbContext>();

            return services;
        }
    }
}
