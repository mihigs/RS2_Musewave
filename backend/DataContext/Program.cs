using DataContext;
using DataContext.Repositories;
using DataContext.Seeder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Models.Entities;
using System.Text.Json;

public class Program
{
    public static async Task Main(string[] args)
    {
        //var host = CreateDefaultApp(args).Build();
        var host = CreateHostBuilder(args).Build();
        using (var scope = host.Services.CreateScope())
        {
            var services = scope.ServiceProvider;
            try
            {
                var context = services.GetRequiredService<MusewaveDbContext>();
                Console.WriteLine("Applying migrations...");
                Console.Write("Connection string: ");
                Console.WriteLine(Environment.GetEnvironmentVariable("ConnectionString"));
                context.Database.Migrate();
                Console.WriteLine("Migrations finished.");

                // Check if the database is already seeded
                if (context.Set<Artist>().Any())
                {
                    Console.WriteLine("Database already seeded. Skipping seeding.");
                    return;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while applying migrations.");
                Console.WriteLine(ex.ToString());
                return;
            }
            try
            {
                Console.WriteLine("Seeding database...");
                var seeder = services.GetRequiredService<MusewaveDbSeeder>();
                await seeder.Seed();
                Console.WriteLine("Seeding finished.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while seeding the database.");
                Console.WriteLine(ex.ToString());
            }
        }
        host.StopAsync().GetAwaiter().GetResult();
    }
    private static IHostBuilder CreateDefaultApp(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionString");
        var listenerApiUrl = Environment.GetEnvironmentVariable("ListenerApiUrl");
        
        var envVars = Environment.GetEnvironmentVariables();
        foreach (var envVar in envVars.Keys)
        {
            Console.WriteLine(envVar + ": " + envVars[envVar]);
        }

        if (string.IsNullOrEmpty(connectionString))
        {
            throw new ArgumentNullException("ConnectionString", "DataContext: Connection string is required.");
        }
        if (string.IsNullOrEmpty(listenerApiUrl))
        {
            throw new ArgumentNullException("ListenerApiUrl", "DataContext: Listener API URL is required.");
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
        builder.UseConsoleLifetime();

        return builder;
    }

    public static IHostBuilder CreateHostBuilder(string[] args)
    {
        return Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration((hostingContext, config) =>
            {
                // Configuration sources have been added by default, including appsettings.json and appsettings.{Environment}.json
                config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                      .AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", optional: true)
                      .AddEnvironmentVariables();
            })
            .ConfigureServices((hostContext, services) =>
            {
                // Access configuration
                var configuration = hostContext.Configuration;

                // Get the connection string from the configuration
                var connectionString = configuration.GetConnectionString("DefaultConnection")
                    ?? throw new InvalidOperationException("DataContext: Connection string 'DefaultConnection' not found.");

                // Get ListenerApiUrl from the configuration
                var listenerApiUrl = configuration.GetValue<string>("ApiSettings:ListenerApiUrl")
                    ?? throw new InvalidOperationException("DataContext: ListenerApiUrl not found.");

                // Configuration and service registration
                services.RegisterDbContext(connectionString) // Make sure this method uses the connection string properly
                        .AddRepositories()
                        .RegisterIdentity();
                services.AddScoped<MusewaveDbSeeder>();
                services.AddScoped<IUnitOfWork, UnitOfWork>();
            });
    }



    //public static IHostBuilder CreateHostBuilder(string[] args)
    //{

    //    var builder = Host.CreateDefaultBuilder(args)
    //        .ConfigureAppConfiguration((hostingContext, config) =>
    //        {
    //        {
    //            config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    //                  .AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", optional: true, reloadOnChange: true);
    //            config.AddEnvironmentVariables(); // This adds environment variables to the configuration system
    //        })

    //        builder.ConfigureServices((hostContext, services) =>
    //        {
    //            // Configuration and service registration
    //            services.RegisterDbContext(connectionString)
    //                .AddRepositories()
    //                .RegisterIdentity();
    //            services.AddScoped<MusewaveDbSeeder>();
    //            services.AddScoped<IUnitOfWork, UnitOfWork>();
    //        });
    //}

}
