using Microsoft.Extensions.DependencyInjection;
using Services.Implementations;

namespace Services
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            services.AddScoped<UsersService>();
            services.AddScoped<AlbumService>();

            return services;
        }
    }
}
