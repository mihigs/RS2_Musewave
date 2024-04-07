using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Services.Interfaces;

namespace Services.Implementations.BackgroundServices
{
    public class JamendoBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _runTime;

        public JamendoBackgroundService(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
            _runTime = new TimeSpan(3, 0, 0); // Run daily at 03:00
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    _serviceProvider.GetRequiredService<ServiceRunControl>().NotifyJamendoServiceDone(); // Skip run
                    await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Initial delay

                    Console.WriteLine("Getting Jamendo Tracks");
                    await LoadJamendoTracksPerGenres();
                    Console.WriteLine("Finished getting Jamendo Tracks");

                    _serviceProvider.GetRequiredService<ServiceRunControl>().NotifyJamendoServiceDone(); // Notify GenreSimilarityTracker

                    await Task.Delay(TimeSpan.FromDays(1), stoppingToken); // Every day
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in JamendoBackgroundService: {ex.Message}");
            }
        }

        private async Task LoadJamendoTracksPerGenres()
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var jamendoService = scope.ServiceProvider.GetRequiredService<IJamendoService>();
                var genreRepository = scope.ServiceProvider.GetRequiredService<IGenreRepository>();

                var genres = await genreRepository.GetAll();

                foreach (var genre in genres)
                {
                    // Tracks are automatically processed by the Jamendo service (add or update to db)
                    await jamendoService.GetJamendoTracksPerGenres(new[] { genre.Name });
                }
            }
        }
    }
}