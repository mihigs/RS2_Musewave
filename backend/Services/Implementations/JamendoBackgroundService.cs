using DataContext.Repositories.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Services.Interfaces;

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
        //await LoadJamendoTracksPerGenres(); // Initial load at startup.

        while (!stoppingToken.IsCancellationRequested)
        {
            var now = DateTime.Now;
            var nextRun = now.Date.Add(_runTime);
            if (now >= nextRun)
            {
                nextRun = nextRun.AddDays(1);
            }

            var waitTime = nextRun - now;
            if (waitTime > TimeSpan.Zero)
            {
                await Task.Delay(waitTime, stoppingToken);
            }

            await LoadJamendoTracksPerGenres();
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
                // Assuming GetJamendoTracksPerGenres expects an array or a list
                var tracks = await jamendoService.GetJamendoTracksPerGenres(new[] { genre.Name });
                // Process tracks as needed
            }
        }
    }
}
