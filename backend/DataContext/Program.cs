using DataContext;
using DataContext.Repositories;
using DataContext.Seeder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Models.Entities;

public class Program
{
    public static async Task Main(string[] args)
    {
        var host = CreateDefaultApp(args).Build();
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
        builder.UseConsoleLifetime();

        return builder;
    }
}
