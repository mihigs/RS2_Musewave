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
            services.AddScoped<IPlaylistTrackRepository, PlaylistTrackRepository>();
            services.AddScoped<ITrackGenreRepository, TrackGenreRepository>();

            return services;
        }
        public static IServiceCollection RegisterDbContext(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<MusewaveDbContext>(options =>
            {
                options.UseSqlServer(connectionString, x => x.MigrationsAssembly("DataContext.Migrations"));
            }, ServiceLifetime.Scoped);

            return services;
        }
        public static IServiceCollection RegisterIdentity(this IServiceCollection services)
        {

            services.AddIdentityCore<User>(options =>
            {
                options.User.RequireUniqueEmail = true;
                options.Password.RequireDigit = true;
                options.Password.RequireUppercase = true;
                options.Password.RequireNonAlphanumeric = true;
            })
            .AddEntityFrameworkStores<MusewaveDbContext>();

            return services;
        }
    }
}
