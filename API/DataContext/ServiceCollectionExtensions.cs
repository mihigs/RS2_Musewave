using Microsoft.Extensions.DependencyInjection;
using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using Models.Entities;
using Microsoft.AspNetCore.Identity;

namespace DataContext
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped<IAlbumRepository, AlbumRepository>();
            services.AddScoped<IArtistRepository, ArtistRepository>();
            services.AddScoped<IGenreRepository, GenreRepository>();
            services.AddScoped<ILikeRepository, LikeRepository>();
            services.AddScoped<IPlaylistRepository, PlaylistRepository>();
            services.AddScoped<ITrackRepository, TrackRepository>();
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IPlaylistTrackRepository, PlaylistTrackRepository>();
            services.AddScoped<ITrackGenreRepository, TrackGenreRepository>();
            services.AddScoped<ILoginActivityRepository, LoginActivityRepository>();
            services.AddScoped<IJamendoApiActivityRepository, JamendoApiActivityRepository>();

            return services;
        }
        public static IServiceCollection RegisterDbContext(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<MusewaveDbContext>(options =>
            {
                options.UseSqlServer(connectionString, b => b.MigrationsAssembly("DataContext"));
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
            .AddUserManager<UserManager<User>>()
            .AddRoles<IdentityRole>()
            .AddRoleManager<RoleManager<IdentityRole>>()
            .AddEntityFrameworkStores<MusewaveDbContext>();

            return services;
        }
    }
}
