using DataContext;
using DataContext.Repositories;
using DataContext.Seeder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

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
                return;
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
    private static IHostBuilder CreateDefaultApp(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("DbConnectionString");

        if (string.IsNullOrEmpty(connectionString))
        {
            throw new ArgumentNullException("ConnectionString", "Connection string is required.");
        }

        var builder = Host.CreateDefaultBuilder(args);
        builder.ConfigureServices((hostContext, services) =>
        {
            services.RegisterDbContext(connectionString)
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
