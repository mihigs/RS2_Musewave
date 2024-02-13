using DataContext;
using DataContext.Repositories;
using DataContext.Repositories.Interfaces;
using DataContext.Seeder;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Models.Entities;

public class Program
{
    public static async Task Main(string[] args)
    {
        var host = CreateDefaultApp(args).Build();
        using (var scope = host.Services.CreateScope())
        {
            var services = scope.ServiceProvider;
            var logger = services.GetRequiredService<ILogger<Program>>();
            try
            {
                var context = services.GetRequiredService<MusewaveDbContext>();
                logger.LogInformation("Applying migrations...");
                context.Database.Migrate();
                logger.LogInformation("Migrations finished.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while applying migrations.");
            }
            try
            {
                logger.LogInformation("Seeding database...");
                var seeder = services.GetRequiredService<MusewaveDbSeeder>();
                await seeder.Seed();
                logger.LogInformation("Seeding finished.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "An error occurred while seeding the database.");
            }
        }
        host.StopAsync().GetAwaiter().GetResult();
    }
    private static IHostBuilder CreateDefaultApp(string[] args) // todo: refactor
    {
        var builder = Host.CreateDefaultBuilder(args);
        builder.ConfigureAppConfiguration((hostingContext, config) =>
        {
            var path = Path.Combine(Directory.GetCurrentDirectory(), "appsettings.json");
            config.AddJsonFile(path, optional: false, reloadOnChange: true);
        });
        builder.ConfigureServices((hostContext, services) =>
        {
            var configuration = hostContext.Configuration;
            var configurationManager = new ConfigurationManager();
            configurationManager.AddConfiguration(configuration);

            services.RegisterDbContext(configuration.GetConnectionString("DefaultConnection"))
                    .AddRepositories()
                    .RegisterIdentity();
            services.AddScoped<MusewaveDbSeeder>();
            services.AddScoped<IUnitOfWork, UnitOfWork>();
        });
        builder.ConfigureLogging(conf =>
        {
            conf.ClearProviders();
            conf.AddConsole();
        });
        builder.UseConsoleLifetime();

        return builder;
    }
}
