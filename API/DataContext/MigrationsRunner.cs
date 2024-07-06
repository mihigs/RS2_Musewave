using DataContext.Seeder;
using Microsoft.EntityFrameworkCore;
using Models.Entities;

namespace DataContext
{
    public class MigrationsRunner
    {
        private readonly MusewaveDbContext _context;
        private readonly MusewaveDbSeeder _seeder;
        public MigrationsRunner(MusewaveDbContext context, MusewaveDbSeeder musewaveDbSeeder)
        {
            _context = context;
            _seeder = musewaveDbSeeder;
        }

        public async Task RunMigrations()
        {
            try
            {
                Console.WriteLine("Applying migrations...");

                Console.Write("Db Connection string: ");
                Console.WriteLine(Environment.GetEnvironmentVariable("ConnectionString"));

                Console.Write("Redis port: ");
                Console.WriteLine(Environment.GetEnvironmentVariable("Redis__Port"));

                await _context.Database.MigrateAsync();
                Console.WriteLine("Migrations finished.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while applying migrations.");
                Console.WriteLine(ex.ToString());
                return;
            }

        }

        public async Task RunSeeder()
        {
            try
            {
                // Check if the database is already seeded
                if (_context.Set<Artist>().Any())
                {
                    Console.WriteLine("Database already seeded. Skipping seeding.");
                    return;
                }
                Console.WriteLine("Seeding database...");
                await _seeder.Seed();
                Console.WriteLine("Seeding finished.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while seeding the database.");
                Console.WriteLine(ex.ToString());
            }
        }
    }
}
