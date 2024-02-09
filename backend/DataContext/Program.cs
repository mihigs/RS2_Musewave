using DataContext;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

public class Program
{
    public static void Main(string[] args)
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
                //var seeder = services.GetRequiredService<MusewaveDbSeeder>();
                logger.LogInformation("Started seeding...");
                //seeder.Seed();
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
        var builder = Host.CreateDefaultBuilder(args);
        builder.ConfigureAppConfiguration((hostingContext, config) =>
        {
            //config.AddJsonFile(appSettingsPath, optional: true, reloadOnChange: true);
        });
        builder.ConfigureServices((hostContext, services) =>
        {
            var configuration = hostContext.Configuration;
            var configurationManager = new ConfigurationManager();
            configurationManager.AddConfiguration(configuration);

            services.AddDbContext<MusewaveDbContext>(options => options.UseSqlServer(hostContext.Configuration.GetConnectionString("DefaultConnection")));

            services.AddIdentityCore<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = true)
                //.AddClaimsPrincipalFactory<AdditionalUserClaimsPrincipalFactory>()
                //.AddDefaultTokenProviders()
                .AddEntityFrameworkStores<MusewaveDbContext>();
            //services.AddScoped<MusewaveDbSeeder>();
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
